import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { JwtService } from '@nestjs/jwt';
import { AuthResponse } from './dto/auth_response.dto';

@Injectable()
export class AuthService {
	constructor(
		private readonly databaseService: DatabaseService,
		private jwtService: JwtService,
	) {
		this.databaseService = databaseService;
	}

	async login(userName: string, password: string): Promise<AuthResponse> {
		const user = await this.databaseService.users.findFirst({
			where: { user_name: userName },
		});

		if (!user) {
			throw new NotFoundException('User not found');
		}

		const isPasswordValid = user.password === password; // Replace with a proper hash comparison in production

		if (!isPasswordValid) {
			throw new NotFoundException('Wrong password');
		}

		// Generate JWT token
		return {
			accessToken: this.jwtService.sign({ userId: user.id }),
			user: {
				id: user.id,
				userName: user.user_name,
				email: user.email,
				phone: user.phone,
			},
		};
	}
}
