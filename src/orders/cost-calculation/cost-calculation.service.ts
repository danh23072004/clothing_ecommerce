import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { VoucherService } from '../../vouchers/vouchers.service';

@Injectable()
export class CostCalculationService {
	constructor(
		private readonly databaseService: DatabaseService,
		private readonly voucherService: VoucherService,
	) {}

	async calculateTotalProductCost(
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

		// Get available voucher amounts
		const availableAmounts =
			await this.voucherService.getAvailableVoucherAmounts(
				userId,
				voucherList,
			);

		// Count voucher occurrences
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
					price *= 1 - product.discount.discount_value / 100;
				} else {
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
					feeAmount =
						Number(product.price) *
						((fee.fee_value || 0) / 100) *
						item.quantity;
				} else {
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
}
