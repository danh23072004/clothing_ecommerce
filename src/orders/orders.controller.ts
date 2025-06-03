import { Controller, Get, Post, Body, Param, UseGuards, Req } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { CreateOrderSingleProductDto } from './dto/create_order_single_product';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { User } from '../decorators/user.decorator';
import { users } from '../../generated/prisma';
import { ApiBearerAuth } from '@nestjs/swagger';

@Controller('orders')
export class OrdersController {
	constructor(private readonly ordersService: OrdersService) {}

	@Post()
	@UseGuards(JwtAuthGuard)
	@ApiBearerAuth()
	create(
		@Body() createOrderDto: CreateOrderSingleProductDto,
		@User() user: users,
	) {
		return this.ordersService.orderSingleProduct(createOrderDto, user.id);
	}

	@Get()
	@UseGuards(JwtAuthGuard)
	@ApiBearerAuth()
	findAll() {
		return this.ordersService.findAll();
	}

	@Get(':id')
	@UseGuards(JwtAuthGuard)
	@ApiBearerAuth()
	findOne(@Param('id') id: string) {
		return this.ordersService.findOne(+id);
	}
}
