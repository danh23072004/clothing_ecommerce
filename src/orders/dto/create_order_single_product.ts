import {
	IsArray,
	IsInt,
	IsNotEmpty,
	IsOptional,
	IsBoolean,
	IsDate,
} from 'class-validator';

export class CreateOrderSingleProductDto {
	@IsInt()
	@IsNotEmpty()
	userId: number;

	@IsInt()
	@IsNotEmpty()
	locationId: number;

	@IsDate()
	@IsNotEmpty()
	date: Date;

	@IsBoolean()
	@IsNotEmpty()
	paymentMethod: boolean; // true for paid/pending, false for unpaid (e.g., cash on delivery)

	@IsArray()
	@IsNotEmpty()
	products: { productId: number; quantity: number };

	@IsOptional()
	@IsArray()
	voucherIds?: number[]; // Optional voucher IDs for discounts
}
