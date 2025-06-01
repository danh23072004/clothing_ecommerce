import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { DatabaseService } from '../database/database.service';

@Injectable()
export class UsersService {
	constructor(private readonly databaseService: DatabaseService) {}
	create(createUserDto: CreateUserDto) {
		return 'This action adds a new user';
	}

	async findAll() {
		return this.databaseService.users.findMany({
			orderBy: { id: 'asc' },
		});
	}

	async findOne(id: number) {
		return this.databaseService.users.findUnique({
			where: { id },
		});
	}

	update(id: number, updateUserDto: UpdateUserDto) {
		return `This action updates a #${id} user`;
	}
}
