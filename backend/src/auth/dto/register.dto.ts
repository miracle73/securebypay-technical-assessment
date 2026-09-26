import { Transform } from 'class-transformer';
import { IsEmail, IsString, Matches, MaxLength, MinLength } from 'class-validator';
import { normalizeEmail, stripPhoneSeparators, trim } from './transforms';

export class RegisterDto {
  @Transform(trim)
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  firstName: string;

  @Transform(trim)
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  lastName: string;

  @Transform(normalizeEmail)
  @IsEmail()
  email: string;

  @Transform(stripPhoneSeparators)
  @Matches(/^\+\d{7,15}$/, { message: 'phone must be in international format, e.g. +2348012345678' })
  phone: string;

  @IsString()
  @MinLength(8)
  @MaxLength(72) // bcrypt only uses the first 72 bytes
  @Matches(/(?=.*[A-Za-z])(?=.*\d)/, { message: 'password must contain a letter and a number' })
  password: string;
}
