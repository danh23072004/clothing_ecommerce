import { Module } from '@nestjs/common';
import { DatabaseModule } from './database/database.module';
import { ProductsModule } from './products/products.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { OrdersModule } from './orders/orders.module';

@Module({
	imports: [DatabaseModule, ProductsModule, UsersModule, AuthModule, OrdersModule],
})
export class AppModule {}
