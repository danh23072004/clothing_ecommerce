import { PartialType } from '@nestjs/swagger';
import { CreateOrderSingleProductDto } from './create_order_single_product';

export class UpdateOrderDto extends PartialType(CreateOrderSingleProductDto) {}
