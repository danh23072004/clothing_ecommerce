//src/auth/entity/auth.entity.ts
import { ApiProperty } from '@nestjs/swagger';

export class AuthResponse {
	@ApiProperty()
	accessToken: string;

	@ApiProperty()
	user: {
		id: number;
		userName: string | null;
		email: string | null;
		phone: string | null;
	};
}
