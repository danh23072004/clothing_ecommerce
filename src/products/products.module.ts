import { Module } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { DatabaseModule } from 'src/database/database.module';

@Module({
	controllers: [ProductsController],
	providers: [ProductsService],
	imports: [DatabaseModule],
})
export class ProductsModule {}
