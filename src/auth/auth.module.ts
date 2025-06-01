import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { jwtConstants } from './config/constants';
import { UsersModule } from '../users/users.module';
import { DatabaseModule } from '../database/database.module';
import { AuthJwtStrategy } from './auth.jwtStrategy';

@Module({
	imports: [
		UsersModule,
		PassportModule,
		DatabaseModule,
		JwtModule.register({
			secret: jwtConstants.secret,
			signOptions: { expiresIn: '30m' }, // e.g. 30s, 7d, 24h
		}),
	],
	controllers: [AuthController],
	providers: [AuthService, AuthJwtStrategy],
})
export class AuthModule {}
