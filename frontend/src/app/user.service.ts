import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { User } from './user';
import { environment } from '../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private http = inject(HttpClient);

  readonly url = environment.API_URL + 'users';

  findAll(): Observable<User[]> {
    return this.http.get<User[]>(this.url);
  }

  save(user: Omit<User, 'id'>): Observable<User> {
    return this.http.post<User>(this.url, user);
  }
}
