//src/auth/dto/login.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class LoginDto {
	@IsNotEmpty()
	@ApiProperty()
	userName: string;

	@IsString()
	@IsNotEmpty()
	@MinLength(6)
	@ApiProperty()
	password: string;
}
