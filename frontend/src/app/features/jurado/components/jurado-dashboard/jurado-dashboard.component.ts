import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { AuthService } from '@core/auth/auth.service';

interface JuradoStats {
  inscriptions_assigned: number;
  pending_evaluations: number;
  completed_evaluations: number;
  average_score: number;
}

interface InscriptionToEvaluate {
  id: string;
  artist_name: string;
  stage_name: string;
  category: string;
  subcategory: string;
  status: string;
  submitted_at: string;
  evaluation_status: 'pending' | 'in_progress' | 'completed';
  score?: number;
}

@Component({
  selector: 'app-jurado-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './jurado-dashboard.component.html',
  styleUrl: './jurado-dashboard.component.css'
})
export class JuradoDashboardComponent implements OnInit {
  auth = inject(AuthService);

  stats = signal<JuradoStats | null>(null);
  pendingInscriptions = signal<InscriptionToEvaluate[]>([]);

  ngOnInit(): void {
    this.loadStats();
    this.loadInscriptions();
  }

  private loadStats(): void {
    this.stats.set({
      inscriptions_assigned: 8,
      pending_evaluations: 5,
      completed_evaluations: 3,
      average_score: 7.5
    });
  }

  private loadInscriptions(): void {
    this.pendingInscriptions.set([
      {
        id: '1',
        artist_name: 'Carlos Méndez',
        stage_name: 'El Trovero',
        category: 'Música',
        subcategory: 'Solista Vocal',
        status: 'pending',
        submitted_at: '2026-06-20T10:00:00Z',
        evaluation_status: 'pending'
      },
      {
        id: '2',
        artist_name: 'María García',
        stage_name: 'María del Sur',
        category: 'Danza',
        subcategory: 'Pareja Tradicional',
        status: 'pending',
        submitted_at: '2026-06-19T14:30:00Z',
        evaluation_status: 'in_progress'
      },
      {
        id: '3',
        artist_name: 'Los Hermanos Rodríguez',
        stage_name: '',
        category: 'Música',
        subcategory: 'Conjunto Folklórico',
        status: 'pending',
        submitted_at: '2026-06-18T09:15:00Z',
        evaluation_status: 'pending'
      },
      {
        id: '4',
        artist_name: 'Ana Lucía Paredes',
        stage_name: 'Anita la Voz del Malvinas',
        category: 'Música',
        subcategory: 'Solista Instrumental',
        status: 'pending',
        submitted_at: '2026-06-17T16:45:00Z',
        evaluation_status: 'pending'
      },
      {
        id: '5',
        artist_name: 'Grupo Raíces',
        stage_name: '',
        category: 'Danza',
        subcategory: 'Grupo Danzas',
        status: 'pending',
        submitted_at: '2026-06-16T11:20:00Z',
        evaluation_status: 'pending'
      }
    ]);
  }

  getInitials(name: string): string {
    return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
  }

  formatDate(dateStr: string): string {
    const d = new Date(dateStr);
    return d.toLocaleDateString('es-AR', { day: '2-digit', month: 'short' });
  }

  getProgressPercent(): number {
    const s = this.stats();
    if (!s || s.inscriptions_assigned === 0) return 0;
    return Math.round((s.completed_evaluations / s.inscriptions_assigned) * 100);
  }
}
