import { Transform } from 'class-transformer';
import { IsEmail, IsString, Matches, MaxLength, MinLength } from 'class-validator';

const trim = ({ value }: { value: unknown }) => (typeof value === 'string' ? value.trim() : value);
const normEmail = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim().toLowerCase() : value;

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

  @Transform(normEmail)
  @IsEmail()
  email: string;

  @Transform(({ value }) => (typeof value === 'string' ? value.replace(/[\s-]/g, '') : value))
  @Matches(/^\+\d{7,15}$/, { message: 'phone must be in international format, e.g. +2348012345678' })
  phone: string;

  @IsString()
  @MinLength(8)
  @MaxLength(72) // bcrypt ignores bytes beyond 72
  @Matches(/(?=.*[A-Za-z])(?=.*\d)/, { message: 'password must contain a letter and a number' })
  password: string;
}

export class LoginDto {
  @Transform(normEmail)
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(1)
  password: string;
}
