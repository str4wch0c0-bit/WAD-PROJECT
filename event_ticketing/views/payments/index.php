<?php ob_start();
$totalUnpaid = count(array_filter($payments, fn($p) => $p['status'] === 'unpaid'));
$totalPaid   = count(array_filter($payments, fn($p) => $p['status'] === 'paid'));
$totalFailed = count(array_filter($payments, fn($p) => $p['status'] === 'failed'));
?>
<div>
    <div style="margin-bottom:24px;">
        <h1 style="font-size:1.9rem;font-weight:800;color:var(--ink);">Verifikasi Pembayaran</h1>
        <p style="color:var(--muted);font-size:0.84rem;margin-top:3px;">Konfirmasi atau tolak pembayaran yang masuk.</p>
    </div>

    <!-- Stats -->
    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:20px;">
        <div style="background:#fff;border:1.5px solid #FEF3C7;border-radius:12px;padding:16px 18px;">
            <p style="font-size:0.68rem;font-weight:700;letter-spacing:0.07em;text-transform:uppercase;color:#92400E;margin-bottom:3px;">Menunggu</p>
            <p style="font-size:1.7rem;font-weight:800;color:#B45309;"><?= $totalUnpaid ?></p>
        </div>
        <div style="background:#fff;border:1.5px solid var(--blue-pale);border-radius:12px;padding:16px 18px;">
            <p style="font-size:0.68rem;font-weight:700;letter-spacing:0.07em;text-transform:uppercase;color:#1E40AF;margin-bottom:3px;">Terverifikasi</p>
            <p style="font-size:1.7rem;font-weight:800;color:var(--blue-mid);"><?= $totalPaid ?></p>
        </div>
        <div style="background:#fff;border:1.5px solid #FEE2E2;border-radius:12px;padding:16px 18px;">
            <p style="font-size:0.68rem;font-weight:700;letter-spacing:0.07em;text-transform:uppercase;color:#991B1B;margin-bottom:3px;">Ditolak</p>
            <p style="font-size:1.7rem;font-weight:800;color:var(--danger);"><?= $totalFailed ?></p>
        </div>
    </div>

    <div style="background:#fff;border-radius:14px;border:1px solid var(--border);overflow:hidden;box-shadow:var(--shadow-card);">
        <div style="overflow-x:auto;">
            <table class="data-table">
                <thead><tr>
                    <th>Kode Tiket</th>
                    <th>Pemesan</th>
                    <th>Acara</th>
                    <th>Qty</th>
                    <th>Total</th>
                    <th>Metode</th>
                    <th>Tgl Bayar</th>
                    <th>Status</th>
                    <th style="text-align:right;">Aksi</th>
                </tr></thead>
                <tbody>
                <?php foreach ($payments as $p): ?>
                <tr>
                    <td style="font-family:monospace;font-weight:700;color:var(--blue-mid);font-size:0.8rem;"><?= htmlspecialchars($p['ticket_code'] ?? 'T-DEL') ?></td>
                    <td style="font-size:0.85rem;font-weight:600;"><?= htmlspecialchars($p['user_name'] ?? '-') ?></td>
                    <td style="font-size:0.82rem;color:var(--ink-soft);"><?= htmlspecialchars($p['event_name'] ?? '-') ?></td>
                    <td>
                        <span style="background:var(--blue-pale);color:var(--blue-deep);font-size:0.78rem;font-weight:700;padding:2px 8px;border-radius:4px;">
                            <?= $p['qty'] ?? 1 ?>×
                        </span>
                    </td>
                    <td style="font-weight:800;color:var(--ink);">Rp <?= number_format($p['amount'],0,',','.') ?></td>
                    <td style="text-transform:capitalize;font-size:0.83rem;"><?= htmlspecialchars($p['method']) ?></td>
                    <td style="color:var(--muted);font-size:0.8rem;"><?= date('d M Y', strtotime($p['payment_date'] ?? 'now')) ?></td>
                    <td>
                        <?php
                        $sl = ['paid'=>['LUNAS','badge-paid'],'unpaid'=>['PENDING','badge-unpaid'],'failed'=>['DITOLAK','badge-failed']][$p['status']] ?? ['PENDING','badge-unpaid'];
                        ?>
                        <span class="badge <?= $sl[1] ?>"><?= $sl[0] ?></span>
                    </td>
                    <td style="text-align:right;">
                        <?php if ($p['status']==='unpaid' && isset($p['ticket_code'])): ?>
                        <div style="display:flex;gap:5px;justify-content:flex-end;">
                            <a href="?controller=payment&action=confirm&id=<?= $p['id'] ?>"
                               style="background:#D1FAE5;color:#065F46;padding:5px 11px;border-radius:6px;font-size:0.75rem;font-weight:700;text-decoration:none;border:1px solid #A7F3D0;white-space:nowrap;"
                               onclick="return confirm('Verifikasi pembayaran ini?');">✓ Verify</a>
                            <a href="?controller=payment&action=reject&id=<?= $p['id'] ?>"
                               style="background:#FEE2E2;color:#991B1B;padding:5px 11px;border-radius:6px;font-size:0.75rem;font-weight:700;text-decoration:none;border:1px solid #FECACA;white-space:nowrap;"
                               onclick="return confirm('Tolak &amp; batalkan tiket ini?');">✕ Tolak</a>
                        </div>
                        <?php else: ?>
                        <span style="font-size:0.77rem;color:var(--muted);font-style:italic;">Selesai</span>
                        <?php endif; ?>
                    </td>
                </tr>
                <?php endforeach; ?>
                <?php if (empty($payments)): ?>
                <tr><td colspan="9" style="text-align:center;color:var(--muted);padding:40px;">Belum ada data.</td></tr>
                <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php $content = ob_get_clean(); require_once __DIR__ . '/../layouts/main.php'; ?>