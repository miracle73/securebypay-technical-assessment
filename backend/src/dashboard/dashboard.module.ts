import {
  Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn, Repository,
} from 'typeorm';
import { Controller, Get, Injectable, Module, Query, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { InjectRepository, TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../users/user.entity';

export type ShipmentStatus = 'in_transit' | 'delayed' | 'delivered';
export type ShipmentDirection = 'export' | 'import';

@Entity('shipments')
export class Shipment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  user: User;

  @Column()
  trackingId: string;

  @Column()
  sender: string;

  @Column()
  receiver: string;

  @Column()
  pickUpFrom: string;

  @Column()
  deliveryTo: string;

  @Column('numeric', { precision: 12, scale: 2 })
  amount: string;

  @Column()
  status: ShipmentStatus;

  @Column()
  direction: ShipmentDirection;

  @Column({ default: false })
  paid: boolean;

  @Column()
  processingHours: number;

  @CreateDateColumn()
  createdAt: Date;
}

@Injectable()
export class DashboardService {
  constructor(@InjectRepository(Shipment) private readonly shipments: Repository<Shipment>) {}

  /**
   * New accounts have no activity, so we seed a few demo shipments on sign-up
   * to give the dashboard (designed around populated data) something to show.
   */
  async seedFor(user: User) {
    const base = { user, sender: 'Bunmi Tanny', receiver: 'Mercy', pickUpFrom: 'Lagos, Nigeria', deliveryTo: 'Oyo Nigeria', amount: '3000', processingHours: 10 };
    await this.shipments.save([
      this.shipments.create({ ...base, trackingId: 'MAF-100-234-291', status: 'in_transit', direction: 'export', paid: true }),
      this.shipments.create({ ...base, trackingId: 'MAF-100-234-292', status: 'delayed', direction: 'import', paid: false }),
      this.shipments.create({ ...base, trackingId: 'MAF-100-234-293', status: 'delivered', direction: 'export', paid: true }),
    ]);
  }

  async overview(user: User) {
    const [total, exports, imports] = await Promise.all([
      this.shipments.count({ where: { user: { id: user.id } } }),
      this.shipments.count({ where: { user: { id: user.id }, direction: 'export' } }),
      this.shipments.count({ where: { user: { id: user.id }, direction: 'import' } }),
    ]);
    return { balance: user.walletBalance, totalShipments: total, totalExports: exports, totalImports: imports };
  }

  recentShipments(user: User, limit = 10) {
    return this.shipments.find({
      where: { user: { id: user.id } },
      order: { createdAt: 'DESC' },
      take: Math.min(Math.max(limit, 1), 50),
    });
  }

  /** Monthly growth series for the chart. Static demo data: there is no real revenue source. */
  growth(period: string) {
    const series: Record<string, number[]> = {
      year: [270, 320, 290, 360, 330, 430, 310, 480, 390, 620, 110, 980],
      month: [200, 260, 240, 300, 350, 330],
      week: [120, 180, 150, 210, 260, 230, 300],
    };
    return { period, points: series[period] ?? series.year };
  }
}

/** All dashboard routes are behind the JWT guard; `req.user` is the loaded User. */
@Controller('dashboard')
@UseGuards(AuthGuard('jwt'))
export class DashboardController {
  constructor(private readonly dashboard: DashboardService) {}

  @Get('overview')
  overview(@Req() req: { user: User }) {
    return this.dashboard.overview(req.user);
  }

  @Get('shipments')
  shipments(@Req() req: { user: User }, @Query('limit') limit?: string) {
    return this.dashboard.recentShipments(req.user, Number(limit) || 10);
  }

  @Get('growth')
  growth(@Query('period') period = 'year') {
    return this.dashboard.growth(period);
  }
}

@Module({
  imports: [TypeOrmModule.forFeature([Shipment])],
  providers: [DashboardService],
  controllers: [DashboardController],
  exports: [DashboardService],
})
export class DashboardModule {}
