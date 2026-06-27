# Épicas e Historias de Usuario - Precosquin

## 1. Artist Registration & Onboarding
- **US-001**: Como artista, quiero **enviar mi formulario de inscripción** solo con **email y teléfono** (sin crear cuenta ni contraseña) para que mis datos queden registrados en la base de datos y puedan ser revisados por la organización y el jurado
- **US-002**: Como artista, quiero seleccionar mi **categoría de participación** al completar el formulario para postularme correctamente:
  - **Música**: Solista vocal, Solista instrumental, Conjunto instrumental, Conjunto vocal, Tema inédito
  - **Danza**: Solista de malambo masculino, Solista de malambo femenino, Pareja tradicional, Pareja estilizada, Conjunto de malambo, Conjunto de baile folklórico
- **US-003**: Como artista, quiero subir documentos requeridos según mi categoría (DNI, CV artístico, rider técnico, audio/video demo) para validar mi inscripción
- **US-004**: Como artista, quiero firmar digitalmente el contrato de participación (enlace único por email) para confirmar mi presencia si soy seleccionado
- **US-005**: Como organizador, quiero revisar y aprobar/rechazar inscripciones filtrando por categoría para curar el lineup
- **US-006**: Como organizador, quiero configurar cupos máximos por categoría y subcategoría para controlar aforos

## 2. Artist Profile Management (vista jurado/organizador)
- **US-007**: Como organizador/jurado, quiero ver la **ficha completa del artista** generada automáticamente desde el formulario (datos personales, categoría, documentos, audio/video) para evaluar su postulación
- **US-008**: Como organizador, quiero editar/agregar información interna a la ficha del artista (notas, estado, asignación de jurado, observaciones) sin que el artista la vea
- **US-009**: Como jurado, quiero ver perfiles de artistas asignados con su música/videos y documentos para evaluar/votar según rúbrica de su categoría

## 3. Event & Calendar Management
- **US-010**: Como organizador, quiero crear y gestionar el cronograma del festival (fechas, escenarios, horarios)
- **US-011**: Como organizador, quiero **comunicar horarios a artistas** (soundcheck, actuación, load-in/load-out) vía email/WhatsApp desde el sistema
- **US-012**: Como staff, quiero asignar camerinos, escenarios y recursos técnicos a cada artista
- **US-013**: Como organizador/staff, quiero notificar cambios de cronograma a artistas afectados por email/WhatsApp

## 4. Jury & Voting System
- **US-014**: Como jurado, quiero acceder a los perfiles asignados y evaluar con rúbricas definidas **por categoría** (música/danza tienen criterios distintos)
- **US-015**: Como jurado, quiero registrar puntajes y comentarios por criterio según categoría:
  - **Música**: técnica vocal/instrumental, originalidad, arreglos, puesta en escena
  - **Danza**: técnica, coreografía, vestuario, expresión escénica, autenticidad folklórica
- **US-016**: Como organizador, quiero configurar categorías, subcategorías, pesos de votación y rondas por cada una
- **US-017**: Como admin, quiero ver resultados consolidados por categoría/subcategoría y exportar actas de premiación

## 5. Organizer Dashboard
- **US-018**: Como organizador, quiero ver dashboard con métricas: inscritos, aprobados, pendientes, completados **desglosados por categoría y subcategoría**
- **US-019**: Como organizador, quiero gestionar comunicaciones masivas por **email/WhatsApp** a artistas por estado **y categoría**
- **US-020**: Como organizador, quiero exportar listados (Excel/PDF) para logística y prensa **filtrados por categoría**

## 6. Admin Panel
- **US-021**: Como admin, quiero gestionar usuarios y roles (crear, editar, desactivar, resetear contraseñas)
- **US-022**: Como admin, quiero configurar parámetros del evento (fechas, cupos, reglas de negocio)
- **US-023**: Como admin, quiero ver logs de auditoría y auditoría de acciones críticas

## 7. Staff Operations
- **US-024**: Como staff, quiero ver checklist de tareas por artista (rider, hospitality, transporte, credenciales)
- **US-025**: Como staff, quiero marcar tareas completadas y reportar incidencias en tiempo real
- **US-026**: Como staff, quiero acceder a info de contacto de artistas y proveedores asignados

## 8. Notifications & Communications
- **US-027**: Como organizador, quiero enviar comunicaciones a artistas por **email y WhatsApp** (sin in-app ni push, ya que no tienen cuenta)
- **US-028**: Como sistema, quiero enviar recordatorios automáticos por email/WhatsApp (soundcheck, deadlines, documentos faltantes, firma contrato)
- **US-029**: Como organizador, quiero crear plantillas de comunicación reutilizables para email y WhatsApp

## 9. Documents & Contracts
- **US-030**: Como artista, quiero firmar contratos y anexos digitalmente vía **enlace único enviado por email** (firma electrónica simple, sin login)
- **US-031**: Como organizador, quiero generar contratos personalizados por artista/grupo automáticamente
- **US-032**: Como admin, quiero almacenar y versionar todos los documentos legales del evento

## 10. Analytics & Reporting
- **US-033**: Como organizador, quiero reportes de inscripción por **categoría (Música/Danza), subcategoría (11 opciones), provincia, experiencia**
- **US-034**: Como organizador, quiero métricas de engagement (**vistas de ficha por jurado/organizador**, descargas rider, firmas contrato) segmentadas por categoría
- **US-035**: Como admin, quiero dashboards técnicos (performance, errores, uso de almacenamiento Supabase)

---

**Total: 35 Historias de Usuario** (US-001 a US-035, 3-4 por épica)
**Roles con acceso al sistema**: Jurado, Organizador, Admin, Staff
**Artista**: Solo envía formulario (sin login/cuenta) - recibe comunicaciones por email/WhatsApp

---

### Catálogos de referencia (para seeds en BD)

**Categoría: MÚSICA**
1. Solista vocal
2. Solista instrumental
3. Conjunto instrumental
4. Conjunto vocal
5. Tema inédito

**Categoría: DANZA**
6. Solista de malambo masculino
7. Solista de malambo femenino
8. Pareja tradicional
9. Pareja estilizada
10. Conjunto de malambo
11. Conjunto de baile folklórico