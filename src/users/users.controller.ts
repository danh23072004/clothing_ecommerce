import { Controller, Get, Post, Body, Patch, Param, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { users } from '../../generated/prisma';
import { User } from '../decorators/user.decorator';
import { ApiBearerAuth } from '@nestjs/swagger';

@Controller('users')
export class UsersController {
	constructor(private readonly usersService: UsersService) {}

	@Get('info')
	@UseGuards(JwtAuthGuard)
	@ApiBearerAuth()
	getUserInfo(@User() user: users) {
		return this.usersService.findOne(user.id);
	}

	@Post()
	create(@Body() createUserDto: CreateUserDto) {
		return this.usersService.create(createUserDto);
	}

	@Get()
	findAll() {
		return this.usersService.findAll();
	}

	@Get(':id')
	findOne(@Param('id') id: string) {
		return this.usersService.findOne(+id);
	}

	@Patch(':id')
	update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
		return this.usersService.update(+id, updateUserDto);
	}
}
