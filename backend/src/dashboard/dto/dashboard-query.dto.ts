import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, Max, Min } from 'class-validator';

export class ShipmentsQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit = 10;
}

export const GROWTH_PERIODS = ['year', 'month', 'week'] as const;
export type GrowthPeriod = (typeof GROWTH_PERIODS)[number];

export class GrowthQueryDto {
  @IsOptional()
  @IsIn(GROWTH_PERIODS)
  period: GrowthPeriod = 'year';
}
