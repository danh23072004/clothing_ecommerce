import { Controller } from '@nestjs/common';
import { VoucherService } from './vouchers.service';

@Controller('vouchers')
export class VouchersController {
	constructor(private readonly vouchersService: VoucherService) {}
}
