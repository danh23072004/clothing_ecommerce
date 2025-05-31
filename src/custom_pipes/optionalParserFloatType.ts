import { PipeTransform, Injectable, BadRequestException } from '@nestjs/common';

@Injectable()
export class OptionalParseFloatPipe implements PipeTransform {
	transform(value: string): number | undefined {
		// If the value is undefined, null, or an empty string, return undefined
		if (value === undefined || value === null || value.trim() === '') {
			return undefined;
		}

		// Attempt to convert the string to a number
		const num = Number(value);

		// If the result is NaN, the input is not a valid number
		if (isNaN(num)) {
			throw new BadRequestException('Invalid number');
		}

		return num;
	}
}
