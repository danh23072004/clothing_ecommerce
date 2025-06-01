// src/users/dto/create-user.dto.ts
import { IsString, IsIn, IsOptional } from 'class-validator';

export class CreateUserDto {
	@IsString()
	@IsIn(['guest', 'registered'])
	user_type: string;

	@IsString()
	@IsOptional()
	name?: string;

	@IsString()
	@IsOptional()
	email?: string;

	@IsString()
	@IsOptional()
	password?: string;

	@IsString()
	@IsOptional()
	phone?: string;

	@IsOptional()
	location_id?: number;

	@IsOptional()
	cart_id?: number;
}
