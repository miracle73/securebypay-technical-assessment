import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { User } from '../users/user.entity';
import { DashboardService } from './dashboard.service';
import { GrowthQueryDto, ShipmentsQueryDto } from './dto/dashboard-query.dto';

@Controller('dashboard')
@UseGuards(JwtAuthGuard)
export class DashboardController {
  constructor(private readonly dashboard: DashboardService) {}

  @Get('overview')
  overview(@CurrentUser() user: User) {
    return this.dashboard.getOverview(user);
  }

  @Get('shipments')
  shipments(@CurrentUser() user: User, @Query() { limit }: ShipmentsQueryDto) {
    return this.dashboard.getRecentShipments(user, limit);
  }

  @Get('growth')
  growth(@Query() { period }: GrowthQueryDto) {
    return this.dashboard.getGrowth(period);
  }
}
