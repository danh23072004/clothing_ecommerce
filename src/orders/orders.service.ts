import { BadRequestException, Injectable } from '@nestjs/common';
import { CreateOrderSingleProductDto } from './dto/create_order_single_product';
import { DatabaseService } from '../database/database.service';
import { CreateOrderCartProducts } from './dto/create_order_cart_products';
import { product } from '../../generated/prisma';

@Injectable()
export class OrdersService {
	constructor(private readonly databaseService: DatabaseService) {}

	// parameters: list of products, userId
	private calculateTotalProductCost(
		productList: { productId: number; quantity: number }[],
		userId: number,
		voucherList: number[] = [],
	) {
		for (const product of productList) {
			// todo
		}
	}

	async orderSingleProduct(createOrderDto: CreateOrderSingleProductDto) {
		/* 3 important information to process
		0. Get the single product
		1. Process Vouchers (comes from createOrderDto.voucherIds)
		2. Process Fees (comes from products)
		3. Process Discounts
		4. Calculate total_product_cost, total_shipping_cost, total_price
		 */

		const single_product: product | null =
			await this.databaseService.product.findUnique({
				where: { id: createOrderDto.products.productId },
			});

		if (!single_product) {
			throw new BadRequestException('Product not found.');
		}

		this.calculateTotalProductCost(
			[
				{
					productId: single_product.id,
					quantity: createOrderDto.products.quantity,
				},
			],
			createOrderDto.userId,
			createOrderDto.voucherIds,
		);

		return null;
	}

	orderCartProducts(createOrderDto: CreateOrderCartProducts) {
		/* 3 important information to process
		0. Get the products from cart
		1. Process Vouchers (comes from createOrderDto.voucherIds)
		2. Process Fees (comes from products)
		3. Process Discounts
		4. Calculate total_product_cost, total_shipping_cost, total_price
		 */

		return null;
	}

	async findAll() {
		return this.databaseService.orders.findMany();
	}

	findOne(id: number) {
		return `This action returns a #${id} order`;
	}
}
