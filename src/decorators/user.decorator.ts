// src/auth/decorators/user.decorator.ts
import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Request } from 'express';
import { users as UserModel } from '../../generated/prisma';

export const User = createParamDecorator(
	(data: keyof UserModel | undefined, ctx: ExecutionContext): unknown => {
		const request = ctx.switchToHttp().getRequest<Request>();
		const user = request.user as UserModel;

		// Return a specific field or the full user
		return data ? user[data] : user;
	},
);
