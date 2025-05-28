import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from 'generated/prisma';

@Injectable()
export class DatabaseService extends PrismaClient implements OnModuleInit {
	async onModuleInit() {
		await this.$connect();
		console.log(`Database connected successfully`);
		const products = await this.product.findMany();
		console.log(`Found ${products.length} products in the database`);
	}
}
