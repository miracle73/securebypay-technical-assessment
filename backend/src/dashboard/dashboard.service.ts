import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/user.entity';
import { GrowthPeriod } from './dto/dashboard-query.dto';
import { Shipment, ShipmentDirection, ShipmentStatus } from './shipment.entity';

/** No revenue source exists yet, so the growth chart is served from fixed series. */
const GROWTH_SERIES: Record<GrowthPeriod, number[]> = {
  year: [270, 320, 290, 360, 330, 430, 310, 480, 390, 620, 110, 980],
  month: [200, 260, 240, 300, 350, 330],
  week: [120, 180, 150, 210, 260, 230, 300],
};

@Injectable()
export class DashboardService {
  constructor(@InjectRepository(Shipment) private readonly shipments: Repository<Shipment>) {}

  /** Gives new accounts something to render; the dashboard is designed around populated data. */
  async seedDemoShipments(user: User) {
    const base = {
      user,
      sender: 'Bunmi Tanny',
      receiver: 'Mercy',
      pickUpFrom: 'Lagos, Nigeria',
      deliveryTo: 'Oyo Nigeria',
      amount: '3000',
      processingHours: 10,
    };
    await this.shipments.insert([
      { ...base, trackingId: 'MAF-100-234-291', status: ShipmentStatus.InTransit, direction: ShipmentDirection.Export, paid: true },
      { ...base, trackingId: 'MAF-100-234-292', status: ShipmentStatus.Delayed, direction: ShipmentDirection.Import, paid: false },
      { ...base, trackingId: 'MAF-100-234-293', status: ShipmentStatus.Delivered, direction: ShipmentDirection.Export, paid: true },
    ]);
  }

  async getOverview(user: User) {
    const counts = await this.shipments
      .createQueryBuilder('s')
      .select('COUNT(*)::int', 'total')
      .addSelect(`COUNT(*) FILTER (WHERE s.direction = :export)::int`, 'exports')
      .addSelect(`COUNT(*) FILTER (WHERE s.direction = :import)::int`, 'imports')
      .where('s.userId = :userId', { userId: user.id })
      .setParameters({ export: ShipmentDirection.Export, import: ShipmentDirection.Import })
      .getRawOne<{ total: number; exports: number; imports: number }>();

    return {
      balance: user.walletBalance,
      totalShipments: counts?.total ?? 0,
      totalExports: counts?.exports ?? 0,
      totalImports: counts?.imports ?? 0,
    };
  }

  getRecentShipments(user: User, limit: number) {
    return this.shipments.find({
      where: { user: { id: user.id } },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  getGrowth(period: GrowthPeriod) {
    return { period, points: GROWTH_SERIES[period] };
  }
}
