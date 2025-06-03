import { Module } from '@nestjs/common';
import { VouchersController } from './vouchers.controller';
import { VoucherService } from './vouchers.service';
import { DatabaseModule } from '../database/database.module';

@Module({
	controllers: [VouchersController],
	providers: [VoucherService],
	imports: [DatabaseModule],
	exports: [VoucherService],
})
export class VouchersModule {}
