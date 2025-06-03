import { IsArray, IsNotEmpty, IsOptional, IsBoolean } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

// This DTO is used for creating an order with a single product by a registered user.
export class CreateOrderSingleProductDto {
	@IsBoolean()
	@IsNotEmpty()
	@ApiProperty()
	paymentMethod: boolean; // true for paid/pending, false for unpaid (e.g., cash on delivery)

	@IsArray()
	@IsNotEmpty()
	@ApiProperty()
	products: { productId: number; quantity: number };

	@IsOptional()
	@IsArray()
	@ApiProperty()
	voucherIds?: number[]; // Optional voucher IDs for discounts
}
