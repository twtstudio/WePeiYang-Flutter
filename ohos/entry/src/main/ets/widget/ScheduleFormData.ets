import { fileIo } from '@kit.CoreFileKit';
import { formBindingData, formProvider } from '@kit.FormKit';

export interface ScheduleCourse {
  name: string;
  location: string;
  time: string;
}

interface ScheduleSnapshot {
  nightMode: boolean;
  days: Record<string, ScheduleCourse[]>;
}

interface ScheduleBinding {
  courses: ScheduleCourse[];
  formDimension: string;
  weekday: number;
  hasData: boolean;
  isEmpty: boolean;
}

const SNAPSHOT = 'schedule_widget.json';
const INSTANCES = 'schedule_widget_instances';

function read(path: string): string {
  try {
    return fileIo.readTextSync(path);
  } catch (_) {
    return '';
  }
}

function write(path: string, value: string): void {
  const temp = path + '.tmp';
  const file = fileIo.openSync(temp, fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC | fileIo.OpenMode.WRITE_ONLY);
  try {
    fileIo.writeSync(file.fd, value);
  } finally {
    fileIo.closeSync(file);
  }
  fileIo.renameSync(temp, path);
}

export function registerScheduleForm(dir: string, id: string, dimension: string): void {
  if (!/^\d+$/.test(id)) return;
  const forms = dir + '/' + INSTANCES;
  if (!fileIo.accessSync(forms)) fileIo.mkdirSync(forms, true);
  write(forms + '/' + id, dimension);
}

export function unregisterScheduleForm(dir: string, id: string): void {
  if (!/^\d+$/.test(id)) return;
  const path = dir + '/' + INSTANCES + '/' + id;
  if (fileIo.accessSync(path)) fileIo.unlinkSync(path);
}

function scheduleSnapshot(dir: string): ScheduleSnapshot | undefined {
  const raw = read(dir + '/' + SNAPSHOT);
  if (!raw) return undefined;
  try {
    return JSON.parse(raw) as ScheduleSnapshot;
  } catch (_) {
    return undefined;
  }
}

export function scheduleBinding(dir: string, dimension: string): formBindingData.FormBindingData {
  const snapshot = scheduleSnapshot(dir);
  const date = new Date();
  if (snapshot?.nightMode && date.getHours() >= 21) date.setDate(date.getDate() + 1);
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const key = date.getFullYear() + '-' + month + '-' + day;
  const courses = snapshot?.days[key] ?? [];
  const binding: ScheduleBinding = {
    courses: courses,
    formDimension: dimension,
    weekday: date.getDay() || 7,
    hasData: snapshot !== undefined,
    isEmpty: courses.length === 0,
  };
  return formBindingData.createFormBindingData(binding);
}

export async function refreshScheduleForm(dir: string, id: string): Promise<void> {
  const dimension = read(dir + '/' + INSTANCES + '/' + id) || '2*2';
  await formProvider.updateForm(id, scheduleBinding(dir, dimension));
  scheduleNextRefresh(dir, id);
}

export function scheduleNextRefresh(dir: string, id: string): void {
  const now = new Date();
  const boundary = new Date(now.getTime());
  if (scheduleSnapshot(dir)?.nightMode) {
    boundary.setHours(21, 0, 0, 0);
    if (boundary.getTime() <= now.getTime()) boundary.setDate(boundary.getDate() + 1);
  } else {
    boundary.setHours(24, 0, 0, 0);
  }
  const minutes = Math.max(5, Math.ceil((boundary.getTime() - now.getTime()) / 60000));
  formProvider.setFormNextRefreshTime(id, minutes).catch(() => {});
}

export async function publishSchedule(dir: string, snapshot: string): Promise<void> {
  const path = dir + '/' + SNAPSHOT;
  if (snapshot) {
    write(path, snapshot);
  } else if (fileIo.accessSync(path)) {
    fileIo.unlinkSync(path);
  }
  const forms = dir + '/' + INSTANCES;
  if (!fileIo.accessSync(forms)) return;
  const ids = fileIo.listFileSync(forms).filter(id => /^\d+$/.test(id));
  await Promise.all(ids.map(id => refreshScheduleForm(dir, id).catch(() => {})));
}
