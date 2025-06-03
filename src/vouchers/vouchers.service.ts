import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

@Injectable()
export class VoucherService {
	constructor(private readonly databaseService: DatabaseService) {}

	async getAvailableVoucherAmounts(
		userId: number,
		voucherList: number[],
	): Promise<{ [key: number]: number }> {
		const userVouchers = await this.databaseService.uservoucher.findMany({
			where: {
				user_id: userId,
				voucher_id: { in: voucherList },
				amount: { gt: 0 },
			},
			select: { voucher_id: true, amount: true },
		});

		const availableAmounts: { [key: number]: number } = {};
		userVouchers.forEach((uv) => {
			availableAmounts[uv.voucher_id] = uv.amount || 0;
		});

		return availableAmounts;
	}

	async decrementVoucherAmounts(
		userId: number,
		voucherIds: number[],
	): Promise<void> {
		await Promise.all(
			voucherIds.map(async (voucherId) => {
				await this.databaseService.uservoucher.updateMany({
					where: {
						user_id: userId,
						voucher_id: voucherId,
						amount: { gt: 0 },
					},
					data: { amount: { decrement: 1 } },
				});
			}),
		);
	}
}