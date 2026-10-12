# Repository Agent Instructions

For AI-assisted work on this public website repository:
- Read this file, README.md and only files relevant to the request.
- Preserve existing pages, app-ads.txt entries, links, hosting settings and site features unless the user explicitly asks to change them.
- Reuse existing scripts and deployment workflows. Avoid unnecessary reinstalls and broad refactors.
- Do not commit credentials, tokens, keys, private user information or build artifacts.
- Verify changes and links where possible. State clearly what was tested and what was not.
- A new chat does not automatically read this file or obtain GitHub access merely because the file exists.

## Zorunlu Windows host izolasyonu (DevLab-Secure)
- ChatGPT, Codex, GitHub ajanlari ve otomatik kod calistirma islemleri Windows ev sahibinde veya eski WSL2 Ubuntu icinde calistirilmayacak. Linux gorevleri yalniz Hyper-V **DevLab-Secure** VM icinde veya yetkili GitHub-hosted runner'da calisir.
- Windows C:, E: ve diger diskler, kullanici profili ve D:\DevLab disindaki her klasor yasaktir. **VM'ye D:\DevLab dahil hicbir Windows klasoru mount edilmez**; VHDX'in D:\DevLab icinde bulunmasi VM'nin host dosyalarini gorebilmesi anlamina gelmez.
- Windows PowerShell/Hyper-V yonetimi yalniz bilgisayar sahibinin manuel guvenlik bakimi icindir; ajanlara host yonetici shell'i, dosya yonlendirmesi, SMB paylasimi, SSH agent forwarding, host Docker socket veya host kimlik bilgileri sunulmaz.
- Isolated self-hosted runner sadece devlab-secure etiketi ve repo basina ayri yetkisiz Linux hesabi ile calisir. Windows/Hyper-V izolasyon denetimi tamamlanmadan runnerlar BASLATILMAZ. Eski devlab-wsl runnerlari ve gorevleri KAPALI tutulur.
- iOS icin macOS GitHub-hosted ve herkese acik site icin GitHub-hosted is akislari istisnadir; bunlar Windows host dosyalarina erisim kazandirmaz.
- Bu metin guvenlik politikasidir, tek basina isletim sistemi izin siniri olusturmaz. Ag ve host erisim sinirlari teknik olarak ayrica test edilir.
