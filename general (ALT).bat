@echo off
chcp 65001 >nul
:: 65001 - UTF-8

cd /d "%~dp0"
call service.bat status_zapret
call service.bat check_updates
call service.bat load_game_filter
echo:

set "BIN=%~dp0bin\"
set "LISTS=%~dp0lists\"
cd /d %BIN%

:: ============================================================
:: МЕГА-АГРЕССИВНАЯ СТРАТЕГИЯ + РОБЛОКС
:: ============================================================

start "zapret: %~n0" /min "%BIN%winws.exe" ^
--wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilter% ^
--wf-udp=443,19294-19344,50000-50100,%GameFilter% ^

:: ===== 1. ROBLOX - TCP (ВЕБ-САЙТЫ И API) =====
--filter-tcp=80,443 --hostlist-domains=roblox.com,*.roblox.com,robloxlabs.com,*.robloxlabs.com,rbxcdn.com,*.rbxcdn.com,robloxcdn.com,*.robloxcdn.com --dpi-desync=fake,fakedsplit --dpi-desync-repeats=16 --dpi-desync-autottl=4 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-ech=split --new ^

:: ===== 2. ROBLOX - UDP (ИГРОВЫЕ СЕРВЕРА) =====
--filter-udp=443 --hostlist-domains=roblox.com,*.roblox.com --dpi-desync=fake --dpi-desync-repeats=16 --dpi-desync-autottl=4 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --dpi-desync-ech=split --new ^

:: ===== 3. ROBLOX - UDP (ИГРОВЫЕ ПОРТЫ 49152-65535) =====
--filter-udp=49152-65535 --hostlist-domains=roblox.com,*.roblox.com --dpi-desync=fake --dpi-desync-repeats=20 --dpi-desync-autottl=5 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-cutoff=n5 --dpi-desync-ech=split --new ^

:: ===== 4. ROBLOX - UDP (ПОРТЫ ГОЛОСОВОГО ЧАТА) =====
--filter-udp=3478,3479,3480,3481,19302,19303,19304,19305,19306,19307,19308,19309,19310 --hostlist-domains=roblox.com,*.roblox.com --filter-l7=stun,webrtc --dpi-desync=fake --dpi-desync-repeats=18 --dpi-desync-autottl=4 --dpi-desync-fake-stun="%BIN%quic_initial_www_google_com.bin" --new ^

:: ===== 5. UDP 443 - ОСНОВНОЙ =====
--filter-udp=443 --hostlist="%LISTS%list-general.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=14 --dpi-desync-autottl=4 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --dpi-desync-ech=split --new ^

:: ===== 6. UDP ИГРЫ/ГОЛОС (Discord, STUN, Zoom, Teams) =====
--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun,zoom,teams --dpi-desync=fake --dpi-desync-repeats=14 --dpi-desync-autottl=4 --dpi-desync-fake-discord="%BIN%quic_initial_www_google_com.bin" --dpi-desync-fake-stun="%BIN%quic_initial_www_google_com.bin" --new ^

:: ===== 7. TCP СПЕЦПОРТЫ (Discord, Google Chat) =====
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media,cdn.discordapp.com,*.discord.com --dpi-desync=fake,hostfakesplit --dpi-desync-repeats=14 --dpi-desync-autottl=4 --dpi-desync-fake-tls-mod=rnd,dupsid,sni=ya.ru --dpi-desync-hostfakesplit-mod=host=ya.ru,altorder=1 --dpi-desync-fooling=ts --dpi-desync-ech=split --new ^

:: ===== 8. TCP 443 - GOOGLE (YouTube, Gmail) =====
--filter-tcp=443 --hostlist="%LISTS%list-google.txt" --ip-id=zero --dpi-desync=fake,hostfakesplit --dpi-desync-repeats=14 --dpi-desync-autottl=4 --dpi-desync-fake-tls-mod=rnd,dupsid,sni=www.google.com --dpi-desync-hostfakesplit-mod=host=www.google.com,altorder=1 --dpi-desync-fooling=ts --dpi-desync-ech=split --new ^

:: ===== 9. TCP 80,443 - ОБЩИЙ СПИСОК =====
--filter-tcp=80,443 --hostlist="%LISTS%list-general.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --dpi-desync=fake,hostfakesplit --dpi-desync-repeats=14 --dpi-desync-autottl=4 --dpi-desync-fake-tls-mod=rnd,dupsid,sni=ya.ru --dpi-desync-hostfakesplit-mod=host=ya.ru,altorder=1 --dpi-desync-fooling=ts --dpi-desync-ech=split --new ^

:: ===== 10. UDP 443 - IPSET ALL (ВСЕ IP) =====
--filter-udp=443 --ipset="%LISTS%ipset-all.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=14 --dpi-desync-autottl=4 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --dpi-desync-ech=split --new ^

:: ===== 11. TCP 80,443 - IPSET ALL (ВСЕ IP) =====
--filter-tcp=80,443,%GameFilter% --ipset="%LISTS%ipset-all.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --dpi-desync=fake,hostfakesplit --dpi-desync-repeats=14 --dpi-desync-autottl=4 --dpi-desync-fake-tls-mod=rnd,dupsid,sni=ya.ru --dpi-desync-hostfakesplit-mod=host=ya.ru,altorder=1 --dpi-desync-fooling=ts --dpi-desync-ech=split --new ^

:: ===== 12. UDP GameFilter - МАКСИМАЛЬНАЯ АГРЕССИЯ =====
--filter-udp=%GameFilter% --ipset="%LISTS%ipset-all.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --dpi-desync=fake --dpi-desync-autottl=4 --dpi-desync-repeats=16 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-cutoff=n4 --dpi-desync-ech=split
