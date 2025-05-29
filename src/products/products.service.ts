import { Injectable } from '@nestjs/common';
import { DatabaseService } from 'src/database/database.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
	constructor(private readonly databaseService: DatabaseService) {}

	/** Creates a new product */
	async create(createProductDto: CreateProductDto) {
		return this.databaseService.product.create({
			data: createProductDto,
		});
	}

	/** Retrieves all products */
	async findAll() {
		// const raw_queries_products = await this.databaseService
		// 	.$queryRaw`SELECT * FROM clothing_ecommerce.product`;
		// console.log('Raw query products:', raw_queries_products);

		const products = await this.databaseService.product.findMany();
		console.log('Products:', products);
		return products;
	}

	/** Retrieves a single product by ID */
	async findOne(id: number) {
		console.log('Products with id ', id);
		return this.databaseService.product.findUnique({
			where: { id },
		});
	}

	/** Updates an existing product */
	async update(id: number, updateProductDto: UpdateProductDto) {
		return this.databaseService.product.update({
			where: { id },
			data: updateProductDto,
		});
	}

	/** Deletes a product by ID */
	async remove(id: number) {
		return this.databaseService.product.delete({
			where: { id },
		});
	}

	/** Retrieves all product categories */
	async getAllCategories() {
		console.log('fetching all categories');
		return this.databaseService.category.findMany();
	}
}
