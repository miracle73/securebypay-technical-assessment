import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  firstName: string;

  @Column()
  lastName: string;

  @Column({ unique: true })
  email: string;

  /** E.164, e.g. +2348012345678. */
  @Column()
  phone: string;

  @Column({ select: false })
  passwordHash: string;

  /** Numeric columns come back from pg as strings, which avoids float rounding on money. */
  @Column('numeric', { precision: 14, scale: 2, default: 0 })
  walletBalance: string;

  @CreateDateColumn()
  createdAt: Date;
}
