import { BadRequestException, Injectable } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
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

	async getProductsByCategory(categoryName: string) {
		return this.databaseService.category.findFirst({
			include: {
				categoryproduct: {
					include: {
						product: true, // Include product details
					},
				},
			},
			where: {
				category_name: categoryName,
			},
		});
	}

	async searchProducts(
		searchTerm: string,
		category?: string,
		minPrice?: number,
		maxPrice?: number,
	) {
		try {
			// Validate search term
			if (!searchTerm) {
				throw new BadRequestException('Search term is required');
			}

			// Format search term for Vietnamese: split words and join with ' & '
			const formattedSearchTerm = searchTerm
				.toLowerCase()
				.split(/\s+/) // Split on whitespace
				.map((word) => word.trim())
				.filter((word) => word.length > 0)
				.join(' & ');

			// Build the raw SQL query with unaccent for diacritic-insensitive search
			let query = `
				SELECT p.*
				FROM "product" p
				WHERE to_tsvector('simple', unaccent(p.name)) @@ to_tsquery('simple', unaccent($1))
			`;
			const params: any[] = [formattedSearchTerm];

			// Add category filter if provided
			if (category) {
				query += `
		  AND p.id IN (
			SELECT cp.product_id
			FROM "categoryproduct" cp
			JOIN "category" c ON cp.category_id = c.id
			WHERE c.category_name = $2
		  )
		`;
				params.push(category);
			}

			// Add price range filters if provided
			if (minPrice !== undefined) {
				query += ` AND p.price >= $${params.length + 1}`;
				params.push(minPrice);
			}
			if (maxPrice !== undefined) {
				query += ` AND p.price <= $${params.length + 1}`;
				params.push(maxPrice);
			}

			// Execute the raw SQL query
			return await this.databaseService.$queryRawUnsafe(query, ...params);
		} catch (error) {
			throw new BadRequestException(`Search failed: ${error}`);
		}
	}
}
