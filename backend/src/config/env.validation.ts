import { plainToInstance } from 'class-transformer';
import { IsBooleanString, IsInt, IsOptional, IsString, MinLength, validateSync } from 'class-validator';

class EnvironmentVariables {
  @IsOptional()
  @IsInt()
  PORT?: number;

  @IsString()
  DATABASE_URL: string;

  @IsOptional()
  @IsBooleanString()
  DATABASE_SSL?: string;

  @IsString()
  @MinLength(16)
  JWT_SECRET: string;

  @IsOptional()
  @IsString()
  JWT_EXPIRES_IN?: string;

  @IsOptional()
  @IsString()
  CORS_ORIGINS?: string;
}

/** Fails fast on boot instead of at the first request that needs a missing value. */
export function validateEnv(config: Record<string, unknown>) {
  const env = plainToInstance(EnvironmentVariables, config, { enableImplicitConversion: true });
  const errors = validateSync(env, { skipMissingProperties: false });
  if (errors.length) {
    throw new Error(`Invalid environment:\n${errors.map((e) => `  - ${Object.values(e.constraints ?? {}).join(', ')}`).join('\n')}`);
  }
  return env;
}
