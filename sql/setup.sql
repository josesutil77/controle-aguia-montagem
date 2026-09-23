-- Cole este arquivo inteiro na aba "SQL Editor" do seu projeto Supabase e clique em "Run".
-- Isso cria a tabela onde ficam guardados os dados dos funcionários,
-- e as regras de segurança (só quem estiver logado pode ver ou alterar os dados).

create table if not exists funcionarios (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  moradia text,
  telefone text,
  cargo text,
  empresa_cliente text,
  empresa_registradora text,
  categoria text,
  salario text,
  data_chegada date,
  status text not null default 'ativo' check (status in ('ativo', 'inativo')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Liga a "trava de segurança" da tabela: por padrão, ninguém acessa nada.
alter table funcionarios enable row level security;

-- Libera acesso total (ver, criar, editar, apagar) só para quem estiver logado no sistema.
create policy "Somente usuarios logados podem ver"
  on funcionarios for select
  to authenticated
  using (true);

create policy "Somente usuarios logados podem inserir"
  on funcionarios for insert
  to authenticated
  with check (true);

create policy "Somente usuarios logados podem atualizar"
  on funcionarios for update
  to authenticated
  using (true);

create policy "Somente usuarios logados podem excluir"
  on funcionarios for delete
  to authenticated
  using (true);

-- Mantém a coluna "updated_at" sempre atualizada automaticamente.
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_funcionarios_updated_at on funcionarios;
create trigger trg_funcionarios_updated_at
  before update on funcionarios
  for each row execute function set_updated_at();
