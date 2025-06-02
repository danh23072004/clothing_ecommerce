import { Controller, Get, Post, Body, Param, UseGuards, Req } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { CreateOrderSingleProductDto } from './dto/create_order_single_product';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('orders')
export class OrdersController {
	constructor(private readonly ordersService: OrdersService) {}

	@Post()
	@UseGuards(JwtAuthGuard)
	create(@Body() createOrderDto: CreateOrderSingleProductDto, @Req() req: Request) {

		return this.ordersService.orderSingleProduct(createOrderDto);
	}

	@Get()
	@UseGuards(JwtAuthGuard)
	findAll() {
		return this.ordersService.findAll();
	}

	@Get(':id')
	@UseGuards(JwtAuthGuard)
	findOne(@Param('id') id: string) {
		return this.ordersService.findOne(+id);
	}
}
