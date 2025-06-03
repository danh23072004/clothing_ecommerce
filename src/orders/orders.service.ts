import { BadRequestException, Injectable } from '@nestjs/common';
import { CreateOrderSingleProductDto } from './dto/create_order_single_product';
import { DatabaseService } from '../database/database.service';
import { CreateOrderCartProducts } from './dto/create_order_cart_products';
import { product } from '../../generated/prisma';

@Injectable()
export class OrdersService {
	constructor(private readonly databaseService: DatabaseService) {}

	private async calculateTotalProductCost(
		productList: { productId: number; quantity: number }[],
		userId: number,
		voucherList: number[] = [],
	): Promise<{
		totalProductCost: number;
		totalFeeCost: number;
		totalPrice: number;
	}> {
		// Fetch products with their discounts and fees
		const products = await this.databaseService.product.findMany({
			where: { id: { in: productList.map((p) => p.productId) } },
			include: {
				discount: true,
				productfee: { include: { fee: true } },
			},
		});

		// Map products for efficient lookup
		const productMap = new Map(products.map((p) => [p.id, p]));

		// Fetch user's available vouchers
		const userVouchers = await this.databaseService.uservoucher.findMany({
			where: {
				user_id: userId,
				voucher_id: { in: voucherList },
				amount: { gt: 0 },
			},
			select: { voucher_id: true, amount: true },
		});
		const availableAmounts: { [key: number]: number } = {};
		userVouchers.forEach((uv) => {
			availableAmounts[uv.voucher_id] = uv.amount || 0;
		});

		// Count voucher occurrences in voucherList
		const voucherCounts: { [key: number]: number } = {};
		voucherList.forEach((voucherId) => {
			voucherCounts[voucherId] = (voucherCounts[voucherId] || 0) + 1;
		});

		let totalProductCost = 0;
		let totalShippingFeeBase = 0;
		let totalPaymentFeeBase = 0;

		// Process each product
		for (const item of productList) {
			const product = productMap.get(item.productId);
			if (!product) continue;

			let price = Number(product.price);

			// Apply discount if it exists
			if (product.discount) {
				if (product.discount.discount_type) {
					// Percentage discount
					price *= 1 - product.discount.discount_value / 100;
				} else {
					// Fixed amount discount
					price -= product.discount.discount_value;
				}
				if (price < 0) price = 0;
			}

			// Apply product vouchers
			const productVouchers =
				await this.databaseService.productvoucher.findMany({
					where: {
						product_id: product.id,
						voucher_id: { in: voucherList },
					},
					include: { voucher: true },
				});

			let totalPercentage = 0;
			let totalFixed = 0;
			for (const pv of productVouchers) {
				const voucherId = pv.voucher_id;
				const applyCount = Math.min(
					voucherCounts[voucherId] || 0,
					availableAmounts[voucherId] || 0,
				);
				if (applyCount > 0 && pv.voucher) {
					if (pv.voucher.is_percentage) {
						totalPercentage += applyCount * (pv.voucher.value || 0);
					} else {
						totalFixed += applyCount * (pv.voucher.value || 0);
					}
				}
			}

			// Apply vouchers: percentage first, then fixed
			price *= 1 - totalPercentage / 100;
			price -= totalFixed;
			if (price < 0) price = 0;

			// Add to total product cost
			totalProductCost += price * item.quantity;

			// Calculate shipping and payment fees
			for (const pf of product.productfee) {
				const fee = pf.fee;
				let feeAmount: number;
				if (fee.amount_type) {
					// Percentage fee based on original price
					feeAmount =
						Number(product.price) *
						((fee.fee_value || 0) / 100) *
						item.quantity;
				} else {
					// Fixed fee
					feeAmount = (fee.fee_value || 0) * item.quantity;
				}

				if (fee.fee_type) {
					totalShippingFeeBase += feeAmount;
				} else {
					totalPaymentFeeBase += feeAmount;
				}
			}
		}

		// Apply shipping vouchers
		const shippingVouchers =
			await this.databaseService.shippingvoucher.findMany({
				where: { voucher_id: { in: voucherList } },
				include: { voucher: true },
			});

		let totalShippingPercentage = 0;
		let totalShippingFixed = 0;
		for (const sv of shippingVouchers) {
			const voucherId = sv.voucher_id;
			const applyCount = Math.min(
				voucherCounts[voucherId] || 0,
				availableAmounts[voucherId] || 0,
			);
			if (applyCount > 0 && sv.voucher) {
				if (sv.voucher.is_percentage) {
					totalShippingPercentage +=
						applyCount * (sv.voucher.value || 0);
				} else {
					totalShippingFixed += applyCount * (sv.voucher.value || 0);
				}
			}
		}

		let adjustedShippingFee =
			totalShippingFeeBase * (1 - totalShippingPercentage / 100) -
			totalShippingFixed;
		if (adjustedShippingFee < 0) adjustedShippingFee = 0;

		// Apply payment vouchers
		const paymentVouchers =
			await this.databaseService.paymentvoucher.findMany({
				where: { voucher_id: { in: voucherList } },
				include: { voucher: true },
			});

		let totalPaymentPercentage = 0;
		let totalPaymentFixed = 0;
		for (const pv of paymentVouchers) {
			const voucherId = pv.voucher_id;
			const applyCount = Math.min(
				voucherCounts[voucherId] || 0,
				availableAmounts[voucherId] || 0,
			);
			if (applyCount > 0 && pv.voucher) {
				if (pv.voucher.is_percentage) {
					totalPaymentPercentage +=
						applyCount * (pv.voucher.value || 0);
				} else {
					totalPaymentFixed += applyCount * (pv.voucher.value || 0);
				}
			}
		}

		let adjustedPaymentFee =
			totalPaymentFeeBase * (1 - totalPaymentPercentage / 100) -
			totalPaymentFixed;
		if (adjustedPaymentFee < 0) adjustedPaymentFee = 0;

		// Calculate total fee cost
		const totalFeeCost = adjustedShippingFee + adjustedPaymentFee;

		// Calculate total price
		const totalPrice = totalProductCost + totalFeeCost;

		return { totalProductCost, totalFeeCost, totalPrice };
	}

	async orderSingleProduct(createOrderDto: CreateOrderSingleProductDto) {
		// Fetch the single product
		const single_product = await this.databaseService.product.findUnique({
			where: { id: createOrderDto.products.productId },
		});

		if (!single_product) {
			throw new BadRequestException('Product not found.');
		}

		// Calculate costs
		const costs = await this.calculateTotalProductCost(
			[
				{
					productId: single_product.id,
					quantity: createOrderDto.products.quantity,
				},
			],
			createOrderDto.userId,
			createOrderDto.voucherIds,
		);

		// Fetch user's location
		const user = await this.databaseService.users.findUnique({
			where: { id: createOrderDto.userId },
			select: { location_id: true },
		});

		if (!user) {
			throw new BadRequestException('User not found.');
		}

		// Create the order
		const order = await this.databaseService.orders.create({
			data: {
				user_id: createOrderDto.userId,
				location_id: user.location_id,
				total_product_cost: costs.totalProductCost,
				total_fee_cost: costs.totalFeeCost,
				payment_method: createOrderDto.paymentMethod,
				total_price: costs.totalPrice,
				orderproduct: {
					create: [
						{
							product_id: single_product.id,
							quantity: createOrderDto.products.quantity,
						},
					],
				},
			},
		});

		// Reduce the amount of vouchers used
		if (createOrderDto.voucherIds && createOrderDto.voucherIds.length > 0) {
			await Promise.all(
				createOrderDto.voucherIds.map(async (voucherId) => {
					await this.databaseService.uservoucher.updateMany({
						where: {
							user_id: createOrderDto.userId,
							voucher_id: voucherId,
							amount: { gt: 0 },
						},
						data: { amount: { decrement: 1 } },
					});
				}),
			);
		}

		return order;
	}

	orderCartProducts(createOrderDto: CreateOrderCartProducts) {
		// TODO: Implement cart product ordering
		return null;
	}

	async findAll() {
		return this.databaseService.orders.findMany();
	}

	findOne(id: number) {
		return `This action returns a #${id} order`;
	}
}
