import {
	IsArray,
	IsInt,
	IsNotEmpty,
	IsOptional,
	IsBoolean,
	IsDate,
} from 'class-validator';

export class CreateOrderCartProducts {
	@IsInt()
	@IsNotEmpty()
	userId: number;

	@IsDate()
	@IsNotEmpty()
	date: Date;

	@IsBoolean()
	@IsNotEmpty()
	paymentMethod: boolean; // true for paid/pending, false for unpaid (e.g., cash on delivery)

	@IsOptional()
	@IsArray()
	voucherIds?: number[]; // Optional voucher IDs for discounts
}
