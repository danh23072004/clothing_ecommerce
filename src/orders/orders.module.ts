import { Module } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrdersController } from './orders.controller';
import { DatabaseModule } from '../database/database.module';
import { CostCalculationService } from './cost-calculation/cost-calculation.service';
import { VouchersModule } from '../vouchers/vouchers.module';

@Module({
	controllers: [OrdersController],
	providers: [OrdersService, CostCalculationService, CostCalculationService],
	imports: [DatabaseModule, VouchersModule],
})
export class OrdersModule {}
