import { IsString, IsDecimal, IsOptional, IsInt, IsIn } from 'class-validator';

export class CreateProductDto {
	@IsInt()
	@IsOptional()
	store_id?: number;

	@IsString()
	@IsIn(['percentage', 'fixed'])
	discount_type: string;

	@IsString()
	name: string;

	@IsDecimal({ decimal_digits: '2', force_decimal: true })
	price: string; // Prisma Decimal is passed as a string in DTOs

	@IsString()
	@IsOptional()
	size?: string;

	@IsInt()
	@IsOptional()
	quantity?: number;

	@IsString()
	@IsOptional()
	color?: string;
}
