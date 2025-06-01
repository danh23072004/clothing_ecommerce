import { Module } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrdersController } from './orders.controller';
import { DatabaseModule } from '../database/database.module';

@Module({
	controllers: [OrdersController],
	providers: [OrdersService],
	imports: [DatabaseModule],
})
export class OrdersModule {}
