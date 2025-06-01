import { Injectable } from '@nestjs/common';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { DatabaseService } from '../database/database.service';

@Injectable()
export class OrdersService {
	constructor(private readonly databaseService: DatabaseService) {}

	create(createOrderDto: CreateOrderDto) {
		return 'This action adds a new order';
	}

	async findAll() {
		return this.databaseService.orders.findMany();
	}

	findOne(id: number) {
		return `This action returns a #${id} order`;
	}
}
