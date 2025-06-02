import {
	Controller,
	Get,
	Post,
	Patch,
	Delete,
	Body,
	Param,
	Query,
} from '@nestjs/common';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { ApiOperation, ApiQuery, ApiResponse } from '@nestjs/swagger';
import { OptionalParseFloatPipe } from '../custom_pipes/optionalParserFloatType';

@Controller('products')
export class ProductsController {
	constructor(private readonly productsService: ProductsService) {}

	@Post()
	create(@Body() createProductDto: CreateProductDto) {
		console.log('Creating a new product:', createProductDto);
		return this.productsService.create(createProductDto);
	}

	@Get()
	findAll() {
		console.log('Fetching all products');
		return this.productsService.findAll();
	}

	// Move /categories route before /:id to avoid route conflict
	@Get('categories')
	getAllCategories() {
		console.log('Fetching all categories');
		return this.productsService.getAllCategories();
	}

	@Get('categories/:category_name')
	getProductsByCategory(@Param('category_name') categoryName: string) {
		console.log(`Fetching products for category: ${categoryName}`);
		return this.productsService.getProductsByCategory(categoryName);
	}

	@Get('search')
	@ApiOperation({
		summary: 'Search products with full-text search and optional filters',
	})
	@ApiQuery({
		name: 'searchTerm',
		type: String,
		required: true,
		description: 'Search term for product names',
	})
	@ApiQuery({
		name: 'category',
		type: String,
		required: false,
		description: 'Filter by category name',
	})
	@ApiQuery({
		name: 'minPrice',
		type: Number,
		required: false,
		description: 'Minimum price filter',
	})
	@ApiQuery({
		name: 'maxPrice',
		type: Number,
		required: false,
		description: 'Maximum price filter',
	})
	@ApiResponse({
		status: 200,
		description: 'List of products matching the search criteria',
	})
	@ApiResponse({
		status: 400,
		description: 'Invalid search term or parameters',
	})
	searchProducts(
		@Query('searchTerm') searchTerm: string,
		@Query('category') category?: string,
		@Query('minPrice', OptionalParseFloatPipe) minPrice?: number,
		@Query('maxPrice', OptionalParseFloatPipe) maxPrice?: number,
	) {
		console.log('searching products...');
		return this.productsService.searchProducts(
			searchTerm,
			category,
			minPrice,
			maxPrice,
		);
	}

	@Get(':id')
	findOne(@Param('id') id: string) {
		console.log(`Fetching product with id: ${id}`);
		return this.productsService.findOne(+id);
	}

	@Patch(':id')
	update(
		@Param('id') id: string,
		@Body() updateProductDto: UpdateProductDto,
	) {
		console.log(`Updating product with id: ${id}`, updateProductDto);
		return this.productsService.update(+id, updateProductDto);
	}

	@Delete(':id')
	remove(@Param('id') id: string) {
		console.log(`Deleting product with id: ${id}`);
		return this.productsService.remove(+id);
	}
}
