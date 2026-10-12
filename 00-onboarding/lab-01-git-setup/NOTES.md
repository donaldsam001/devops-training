# 00-onboarding — lab-01-git-setup

## Môi trường
- **OS:** Ubuntu 26.04 LTS 
- **Git version:** `git version 2.53.0`
- **OpenSSH:** `OpenSSH_10.2p1 Ubuntu-2ubuntu3.6`

## Các bước thực hiện

1. **Tạo SSH key Ed25519 có passphrase và add vào GitHub**
   - *Lệnh:*
     ```bash
     ssh-keygen -t ed25519 -C "you@course.example" -f ~/.ssh/id_ed25519
     eval "$(ssh-agent -s)"
     ssh-add ~/.ssh/id_ed25519
     cat ~/.ssh/id_ed25519.pub # Copy và paste vào GitHub Settings -> SSH and GPG keys
     ssh -T git@github.com
     ```
   - *Output chính:*
     ```text
     Hi <github-username>! You've successfully authenticated, but GitHub does not provide shell access.
     ```

2. **Cấu hình danh tính Git Global bằng email khóa học**
   - *Lệnh:*
     ```bash
     git config --global user.name "Nguyen Van A"
     git config --global user.email "you@course.example"
     git config --global --list
     ```
   - *Output chính:*
     ```text
     user.name=Nguyen Van A
     user.email=you@course.example
     ```

3. **Tạo repo `~/customer-demo` với danh tính riêng (repo-level)**
   - *Lệnh:*
     ```bash
     mkdir -p ~/customer-demo && cd ~/customer-demo
     git init
     git config --local user.name "Nguyen Van A"
     git config --local user.email "you@customer.example"
     echo "Customer Demo" > README.md
     git add README.md
     git commit -m "Initial commit for customer demo"
     git log -1 --format='%an <%ae>'
     ```
   - *Output chính:*
     ```text
     <github-username> <you@customer.example>
     ```

4. **Cấu hình `includeIf` để tự động đổi email cho thư mục `~/customers/`**
   - *Lệnh:*
     ```bash
     # Thêm vào ~/.gitconfig
     git config --global includeIf."gitdir:~/customers/".path "~/.gitconfig-customer"

     # Tạo file cấu hình riêng cho customer
     git config --file ~/.gitconfig-customer user.email "you@customer.example"
     ```
   - *Output chính (`cat ~/.gitconfig`):*
     ```ini
     [user]
     	name = Nguyen Van A
     	email = you@course.example
     [credential]
	    helper = cache
     [includeIf "gitdir:~/customers/"]
     	path = ~/.gitconfig-customer
     ```

5. **Viết và phân quyền thực thi cho `check-identity.sh`**
   - *Lệnh:*
     ```bash
     chmod +x check-identity.sh
     ./check-identity.sh course.example
     ./check-identity.sh wrong.com || echo $?
     ```
   - *Output chính:*
     ```text
     User Name : Nguyen Van A
     User Email: you@course.example
     Remote URL: git@github.com:<username>/devops-training.git
     OK: Email matches domain 'gmail.com'.

     User Name : Nguyen Van A
     User Email: you@course.example
     Remote URL: git@github.com:<username>/devops-training.git
     WARNING: Email domain 'gmail.com' does not match expected domain 'wrong.com'!
     1
     ```

6. **Tạo repo `devops-training`, branch và mở Pull Request**
   - *Lệnh:*
     ```bash
     cd ~/devops-training
     git switch -c feature/lab01
     git add 00-onboarding/lab-01-git-setup/
     git commit -m "#1 00-onboarding lab-01: git setup and identity workflow"
     git push -u origin feature/lab01
     ```
   - *Output chính:*
     ```text
    To github.com:<github-username>/devops-training.git
    * [new branch]      feature/lab01 -> feature/lab01
    branch 'feature/lab01' set up to track 'origin/feature/lab01'.
     ```

## Kết quả và tiêu chí xác minh

### Tiêu chí 1: Kết nối SSH GitHub thành công

**Lệnh kiểm tra:**

```bash
ssh -T git@github.com
```

**Kết quả mong đợi:**

```text
Hi <github-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

### Tiêu chí 2: Cấu hình local ghi đè global

**Tại repository `devops-training`:**

```bash
cd ~/devops-training
git config --list --show-origin | grep 'user\.'
```

**Output mong đợi:**

```text
file:/home/user/.gitconfig    user.name=Nguyen Van A
file:/home/user/.gitconfig    user.email=you@course.example
```

**Tại repository `customer-demo`:**

```bash
cd ~/customer-demo
git config --list --show-origin | grep 'user\.'
```

**Output mong đợi:**

```text
file:/home/user/.gitconfig    user.name=Nguyen Van A
file:/home/user/.gitconfig    user.email=you@course.example
file:.git/config              user.email=you@customer.example
```

> Các đường dẫn và giá trị trên là ví dụ. Kết quả thực tế phụ thuộc vào username, thư mục home và cấu hình máy tính.

### Tiêu chí 3: Email của commit ở hai repository khác nhau

**Repository `devops-training`:**

```bash
cd ~/devops-training
git log -1 --format='%an <%ae>'
```

Kết quả mong đợi:

```text
Nguyen Van A <you@course.example>
```

**Repository `customer-demo`:**

```bash
cd ~/customer-demo
git log -1 --format='%an <%ae>'
```

Kết quả mong đợi:

```text
Nguyen Van A <you@customer.example>
```

### Tiêu chí 4: Exit code của `check-identity.sh`

**Domain đúng:**

```bash
./check-identity.sh course.example
echo $?
```

Kết quả:

```text
0
```

**Domain sai:**

```bash
./check-identity.sh example.com
echo $?
```

Kết quả:

```text
1
```

## Câu hỏi tự kiểm tra 00-onboarding — lab-01-git-setup

### Câu 1: Thứ tự ưu tiên của Git config là gì?

Thứ tự ưu tiên từ thấp đến cao:

1. `system`: `/etc/gitconfig`
2. `global`: `~/.gitconfig`
3. `local`: `.git/config`
4. `worktree`: `.git/config.worktree`, khi cấu hình worktree được bật và hỗ trợ.

Cấu hình ở cấp ưu tiên cao hơn sẽ ghi đè giá trị ở cấp thấp hơn nếu cùng một khóa được thiết lập.

### Câu 2: Đổi `user.email` sau khi commit có làm thay đổi commit cũ không?

Không. Email tác giả được lưu trong metadata của từng commit nên thay đổi cấu hình Git không sửa commit đã tạo.

**Sửa commit gần nhất:**

```bash
git commit --amend --author="Nguyen Van A <new@example.com>" --no-edit
```

**Sửa nhiều commit cũ:** Có thể sử dụng `git rebase -i` hoặc `git-filter-repo`, tùy phạm vi cần chỉnh sửa.

**Rủi ro:** Viết lại lịch sử sẽ thay đổi commit hash. Nếu commit đã được push lên branch dùng chung, việc cập nhật lịch sử có thể ảnh hưởng đến những người cộng tác.

### Câu 3: `git pull` khác `git fetch` thế nào? `merge` khác `rebase` thế nào?

- `git fetch`: Tải thông tin và commit mới từ remote về local nhưng không tự tích hợp vào branch hiện tại.
- `git pull`: Thực hiện fetch rồi tích hợp thay đổi bằng merge hoặc rebase, tùy cấu hình và tùy chọn.
- `git merge`: Tích hợp lịch sử các nhánh, có thể tạo merge commit.
- `git rebase`: Phát lại các commit trên một base mới, thường tạo lịch sử tuyến tính và làm thay đổi commit hash của các commit được phát lại.

### Câu 4: Vì sao không nên `git push --force` lên branch người khác đang sử dụng?

`git push --force` có thể ghi đè lịch sử remote và làm mất các commit mà người khác đã đẩy lên.

`git push --force-with-lease` an toàn hơn vì kiểm tra kỳ vọng về trạng thái remote trước khi ghi đè. Tuy nhiên, đây không phải là sự đảm bảo tuyệt đối rằng không xảy ra mất dữ liệu. Nên kiểm tra lịch sử và phối hợp với nhóm trước khi sử dụng.

### Câu 5: Lỡ `git add .env` và commit thì xử lý thế nào?

**Nếu chưa push:**

```bash
git rm --cached .env
echo ".env" >> .gitignore
git add .gitignore
git commit --amend
```

Nếu file đã nằm trong commit gần nhất, có thể sửa commit bằng `--amend` để loại bỏ `.env` khỏi commit đó. Cần kiểm tra lại trạng thái Git trước khi thực hiện.

**Nếu đã push:**

1. Thu hồi hoặc thay mới ngay các secret, token và password có trong file.
2. Xóa file khỏi trạng thái được theo dõi và thêm vào `.gitignore`.
3. Nếu cần loại bỏ secret khỏi lịch sử, sử dụng công cụ phù hợp như `git-filter-repo` và phối hợp với người quản lý repository trước khi viết lại lịch sử.
4. Kiểm tra các bản sao, fork, cache và log có liên quan.

> Xóa file khỏi commit mới không làm cho secret đã lộ trở nên an toàn. Việc thu hồi hoặc thay mới secret là ưu tiên hàng đầu.

## Câu hỏi tự kiểm tra 00-onboarding
### Câu 1: Trước khi push code lên repository cần kiểm tra gì?

- Danh tính Git:

  ```bash
  git config user.name
  git config user.email
  git log -1 --format='%an <%ae>'
  ```

- Branch hiện tại:

  ```bash
  git branch --show-current
  ```

- File sẽ được commit:

  ```bash
  git status
  git diff --cached
  ```

- Kiểm tra `.env`, private key, token, password và các file không được phép chia sẻ.
- Xác nhận remote URL và quyền truy cập:

  ```bash
  git remote -v
  ```

### Câu 2: Vì sao không nên fork mã nguồn của tổ chức về tài khoản cá nhân?

Việc này có thể vi phạm chính sách bảo mật, quyền sở hữu trí tuệ hoặc thỏa thuận bảo mật (NDA). Repository private không loại bỏ rủi ro vì tổ chức có thể mất quyền kiểm soát đối với bản sao nằm ngoài hệ thống được phê duyệt.

Chỉ sao chép hoặc fork mã nguồn khi được tổ chức cho phép và tuân thủ quy trình đã quy định.

### Câu 3: Lỡ commit password lên Git và đã push thì xóa commit có đủ không?

Không. Secret có thể đã được sao chép hoặc lưu trong lịch sử, clone, cache, log hay các hệ thống khác.

Cần thu hồi hoặc đổi password/token ngay, sau đó xử lý lịch sử Git và thông báo cho người phụ trách bảo mật.

### Câu 4: Vì sao không nên chạy ứng dụng bằng `root` hoặc dùng `chmod 777`?

- Vi phạm nguyên tắc quyền tối thiểu (Least Privilege).
- Tăng phạm vi ảnh hưởng nếu ứng dụng bị khai thác.
- `chmod 777` cho phép mọi người dùng đọc, ghi và thực thi file hoặc thư mục được áp dụng quyền đó.

Nên sử dụng tài khoản dịch vụ riêng và cấp quyền tối thiểu cần thiết.

### Câu 5: Kể ba thao tác khó đảo ngược cần backup hoặc xác nhận trước khi làm

1. `git push --force` lên branch dùng chung.
2. Xóa dữ liệu hoặc format phân vùng, ví dụ `rm -rf /path` hay `mkfs`.
3. Thay đổi dữ liệu cơ sở dữ liệu, ví dụ `DROP DATABASE`, `DROP TABLE` hoặc `DELETE` thiếu điều kiện `WHERE`.

Cần kiểm tra mục tiêu, quyền thực thi, bản backup và phương án khôi phục trước khi thao tác.

### Câu 6: Khi gặp lỗi, cần chuẩn bị thông tin gì trước khi hỏi người khác?

- Mục tiêu và các bước thực hiện.
- Lệnh đã chạy cùng log/output đầy đủ.
- Môi trường và phiên bản công cụ liên quan.
- Kết quả mong đợi và kết quả thực tế.
- Các phương án đã thử và kết quả.
- Thông tin tái hiện lỗi tối thiểu, không bao gồm password, token hoặc secret.

## Vấn đề gặp phải và cách xử lý

## Tổng kết

Sau khi hoàn thành Lab 01, các nội dung nắm vững gồm:

- Tạo SSH key Ed25519 và xác thực GitHub qua SSH.
- Cấu hình danh tính Git ở cấp global và local.
- Hiểu cơ chế ưu tiên của Git config và sử dụng `includeIf`.
- Viết script Bash kiểm tra email và xử lý exit code.
- Thực hành tạo branch, commit, push và mở Pull Request.
- Kiểm tra danh tính commit và phòng tránh đưa secret vào Git.
- Hiểu các thao tác rủi ro và quy trình xử lý sự cố cơ bản.

**Trạng thái:** Hoàn thành khi đã chạy kiểm tra thực tế, lưu lại output của các tiêu chí xác minh và tạo Pull Request theo yêu cầu khóa học.