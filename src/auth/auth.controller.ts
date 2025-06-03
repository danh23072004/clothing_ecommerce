import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { ApiOkResponse } from '@nestjs/swagger';
import { AuthResponse } from './dto/auth_response.dto';
import { LoginDto } from './dto/login.dto';

@Controller('auth')
export class AuthController {
	constructor(private readonly authService: AuthService) {
		// The AuthController is responsible for handling authentication-related requests.
		// It uses the AuthService to perform operations like login, registration, etc.
		// The constructor injects the AuthService to use its methods in the controller.
		this.authService = authService;
	}

	@Post('login')
	// @ApiOkResponse({ type: AuthResponse })
	async login(
		@Body() { userName, password }: LoginDto,
	): Promise<AuthResponse> {
		// This method handles the login request.
		// It calls the AuthService's login method to authenticate the user and return an AuthResponse.
		return this.authService.login(userName, password);
	}
}
