import { Column, CreateDateColumn, Entity, Index, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { User } from '../users/user.entity';

export enum ShipmentStatus {
  InTransit = 'in_transit',
  Delayed = 'delayed',
  Delivered = 'delivered',
}

export enum ShipmentDirection {
  Export = 'export',
  Import = 'import',
}

@Entity('shipments')
@Index(['user', 'createdAt'])
export class Shipment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE', nullable: false })
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

  @Column({ type: 'varchar' })
  status: ShipmentStatus;

  @Column({ type: 'varchar' })
  direction: ShipmentDirection;

  @Column({ default: false })
  paid: boolean;

  @Column('int')
  processingHours: number;

  @CreateDateColumn()
  createdAt: Date;
}
