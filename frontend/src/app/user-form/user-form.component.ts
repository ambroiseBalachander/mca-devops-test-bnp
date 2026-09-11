import { Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { User } from '../user';
import { UserService } from '../user.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './user-form.component.html'
})
export class UserFormComponent {
  private userService = inject(UserService);
  private router = inject(Router);

  user: User = new User();

  onSubmit() {
    this.userService.save(this.user).subscribe(_ =>
      this.router.navigate(['/users'])
    );
  }
}
