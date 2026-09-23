-- Cole este arquivo inteiro na aba "SQL Editor" do Supabase e clique em "Run".
-- Cria as 5 tabelas dos módulos de vencimento, todas ligadas ao cadastro de funcionários.

create table if not exists vencimento_epi (
  id uuid primary key default gen_random_uuid(),
  funcionario_id uuid references funcionarios(id) on delete set null,
  funcionario_nome text not null,
  data_inicial date,
  data_final date,
  empresa_registrado text,
  assinatura text default 'PENDENTE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists vencimento_exames (
  id uuid primary key default gen_random_uuid(),
  funcionario_id uuid references funcionarios(id) on delete set null,
  funcionario_nome text not null,
  data_exame date,
  data_prox_exame date,
  empresa_registrado text,
  assinatura text default 'PENDENTE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists vencimento_nrs (
  id uuid primary key default gen_random_uuid(),
  funcionario_id uuid references funcionarios(id) on delete set null,
  funcionario_nome text not null,
  nr33_vencimento date,
  nr34_vencimento date,
  nr35_vencimento date,
  assinatura text default 'PENDENTE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists folgas_campo (
  id uuid primary key default gen_random_uuid(),
  funcionario_id uuid references funcionarios(id) on delete set null,
  funcionario_nome text not null,
  inicio_trabalho date,
  ultima_folga date,
  obs text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists convocacoes (
  id uuid primary key default gen_random_uuid(),
  funcionario_id uuid references funcionarios(id) on delete set null,
  funcionario_nome text not null,
  data_inicial date,
  data_final date,
  empresa_prestacao_servicos text,
  contrato text,
  assinatura text default 'PENDENTE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Trava de segurança: só quem estiver logado acessa.
alter table vencimento_epi enable row level security;
alter table vencimento_exames enable row level security;
alter table vencimento_nrs enable row level security;
alter table folgas_campo enable row level security;
alter table convocacoes enable row level security;

do $$
declare
  tabela text;
begin
  foreach tabela in array array['vencimento_epi', 'vencimento_exames', 'vencimento_nrs', 'folgas_campo', 'convocacoes']
  loop
    execute format('create policy "usuarios_logados_select" on %I for select to authenticated using (true)', tabela);
    execute format('create policy "usuarios_logados_insert" on %I for insert to authenticated with check (true)', tabela);
    execute format('create policy "usuarios_logados_update" on %I for update to authenticated using (true)', tabela);
    execute format('create policy "usuarios_logados_delete" on %I for delete to authenticated using (true)', tabela);
    execute format('create trigger trg_updated_at before update on %I for each row execute function set_updated_at()', tabela);
  end loop;
end $$;
