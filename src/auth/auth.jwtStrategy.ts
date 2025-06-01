//src/auth/auth.jwtStrategy.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { UsersService } from 'src/users/users.service';
import { jwtConstants } from './config/constants';
import { users } from '../../generated/prisma';

@Injectable()
export class AuthJwtStrategy extends PassportStrategy(Strategy, 'jwt') {
	constructor(private usersService: UsersService) {
		super({
			jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
			secretOrKey: jwtConstants.secret,
		});
	}

	async validate(payload: { userId: number }) {
		const user = await this.usersService.findOne(payload.userId);

		if (!user) {
			throw new UnauthorizedException();
		}

		return user;
	}
}
