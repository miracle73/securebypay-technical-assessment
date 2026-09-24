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

  // Stored as dial code + national number, e.g. "+2348012345678".
  @Column()
  phone: string;

  // select: false keeps the hash out of every query unless explicitly requested.
  @Column({ select: false })
  passwordHash: string;

  // Kobo-free decimal kept as a string by pg to avoid float rounding.
  @Column('numeric', { precision: 14, scale: 2, default: 0 })
  walletBalance: string;

  @CreateDateColumn()
  createdAt: Date;
}
