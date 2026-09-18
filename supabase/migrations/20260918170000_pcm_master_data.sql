-- BIOTROP: PCM/SCI/SCM master-data catalog
create table if not exists public.pcm_master_data (
  id uuid primary key default gen_random_uuid(),
  scope text not null,
  item_key text not null,
  label text not null,
  metadata jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  sort_order integer not null default 0,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint pcm_master_data_scope_key unique (scope,item_key),
  constraint pcm_master_data_scope_chk check (scope in ('scm_time','scm_tipo_solicitacao','scm_camm','scm_urgencia','scm_centro_custo','scm_tipo_fornecedor','scm_tipo_pedido','sci_familia'))
);
create index if not exists idx_pcm_master_data_scope_active_sort on public.pcm_master_data(scope,active,sort_order);
create or replace function private.current_user_role()
returns text language sql stable security definer set search_path=''
as $$ select lower(coalesce(p.role_code,p.app_role,'')) from public.profiles p where p.id=(select auth.uid()) and coalesce(p.active,p.is_active,true)=true limit 1 $$;
revoke all on function private.current_user_role() from public;
grant execute on function private.current_user_role() to authenticated;
alter table public.pcm_master_data enable row level security;
alter table public.pcm_master_data force row level security;
revoke all on table public.pcm_master_data from anon;
grant select,insert,update,delete on public.pcm_master_data to authenticated;
drop policy if exists pcm_master_select on public.pcm_master_data;
create policy pcm_master_select on public.pcm_master_data for select to authenticated using (active=true or (select private.current_user_role()) in ('admin','gestor','pcm','almoxarife'));
drop policy if exists pcm_master_insert on public.pcm_master_data;
create policy pcm_master_insert on public.pcm_master_data for insert to authenticated with check ((select private.current_user_role()) in ('admin','gestor','pcm') or (scope='sci_familia' and (select private.current_user_role())='almoxarife'));
drop policy if exists pcm_master_update on public.pcm_master_data;
create policy pcm_master_update on public.pcm_master_data for update to authenticated using ((select private.current_user_role()) in ('admin','gestor','pcm') or (scope='sci_familia' and (select private.current_user_role())='almoxarife')) with check ((select private.current_user_role()) in ('admin','gestor','pcm') or (scope='sci_familia' and (select private.current_user_role())='almoxarife'));
drop policy if exists pcm_master_delete on public.pcm_master_data;
create policy pcm_master_delete on public.pcm_master_data for delete to authenticated using ((select private.current_user_role()) in ('admin','gestor','pcm') or (scope='sci_familia' and (select private.current_user_role())='almoxarife'));
insert into public.pcm_master_data(scope,item_key,label,metadata,sort_order) values
('scm_time','Elétrica e Automação','Elétrica e Automação','{}'::jsonb,0),
('scm_time','Predial','Predial','{}'::jsonb,1),
('scm_time','Mecânica','Mecânica','{}'::jsonb,2),
('scm_time','PCM','PCM','{}'::jsonb,3),
('scm_time','Almoxarifado','Almoxarifado','{}'::jsonb,4),
('scm_time','Time CAMM 03','Time CAMM 03','{}'::jsonb,5),
('scm_time','Outra','Outra','{}'::jsonb,6),
('scm_tipo_solicitacao','normal','Normal','{}'::jsonb,0),
('scm_tipo_solicitacao','emergencial','Emergencial','{}'::jsonb,1),
('scm_tipo_solicitacao','melhoria_capex','Melhoria/CAPEX','{}'::jsonb,2),
('scm_camm','CAMM 1','CAMM 1','{}'::jsonb,0),
('scm_camm','CAMM 2','CAMM 2','{}'::jsonb,1),
('scm_camm','CAMM 3','CAMM 3','{}'::jsonb,2),
('scm_urgencia','Baixa','Baixa','{}'::jsonb,0),
('scm_urgencia','Média','Média','{}'::jsonb,1),
('scm_urgencia','Alta','Alta','{}'::jsonb,2),
('scm_centro_custo','CENTRO LOGÍSTICO','CENTRO LOGÍSTICO','{"camm":null,"compartilhado":true}'::jsonb,0),
('scm_centro_custo','COMPRAS','COMPRAS','{"camm":null,"compartilhado":true}'::jsonb,1),
('scm_centro_custo','COMPRAS - PRODUÇÃO','COMPRAS - PRODUÇÃO','{"camm":null,"compartilhado":true}'::jsonb,2),
('scm_centro_custo','CONTABILIDADE','CONTABILIDADE','{"camm":null,"compartilhado":true}'::jsonb,3),
('scm_centro_custo','CONTROLE DE QUALIDADE - CAMM 3','CONTROLE DE QUALIDADE - CAMM 3','{"camm":"CAMM 3","compartilhado":false}'::jsonb,4),
('scm_centro_custo','EMPACOTAMENTO - CAMM 1','EMPACOTAMENTO - CAMM 1','{"camm":"CAMM 1","compartilhado":false}'::jsonb,5),
('scm_centro_custo','EMPACOTAMENTO -CAMM 2','EMPACOTAMENTO -CAMM 2','{"camm":"CAMM 2","compartilhado":false}'::jsonb,6),
('scm_centro_custo','ENVASE - CAMM 1','ENVASE - CAMM 1','{"camm":"CAMM 1","compartilhado":false}'::jsonb,7),
('scm_centro_custo','ENVASE - CAMM 2','ENVASE - CAMM 2','{"camm":"CAMM 2","compartilhado":false}'::jsonb,8),
('scm_centro_custo','ESG','ESG','{"camm":null,"compartilhado":true}'::jsonb,9),
('scm_centro_custo','FACILITIES','FACILITIES','{"camm":null,"compartilhado":true}'::jsonb,10),
('scm_centro_custo','FACILITIES - INDUSTRIAL - CAMM 3','FACILITIES - INDUSTRIAL - CAMM 3','{"camm":"CAMM 3","compartilhado":false}'::jsonb,11),
('scm_centro_custo','FACILITIES - PRODUÇÃO','FACILITIES - PRODUÇÃO','{"camm":null,"compartilhado":true}'::jsonb,12),
('scm_centro_custo','FATURAMENTO E EXPEDIÇÃO','FATURAMENTO E EXPEDIÇÃO','{"camm":null,"compartilhado":true}'::jsonb,13),
('scm_centro_custo','FERMENTAÇÃO - CAMM 2','FERMENTAÇÃO - CAMM 2','{"camm":"CAMM 2","compartilhado":false}'::jsonb,14),
('scm_centro_custo','FERMENTAÇÃO - CAMM 3','FERMENTAÇÃO - CAMM 3','{"camm":"CAMM 3","compartilhado":false}'::jsonb,15),
('scm_centro_custo','FERMENTADORES - CAMM 1','FERMENTADORES - CAMM 1','{"camm":"CAMM 1","compartilhado":false}'::jsonb,16),
('scm_centro_custo','FISCAL','FISCAL','{"camm":null,"compartilhado":true}'::jsonb,17),
('scm_centro_custo','FORMULAÇÃO/EMPACOTAMENTO - CAMM 3','FORMULAÇÃO/EMPACOTAMENTO - CAMM 3','{"camm":"CAMM 3","compartilhado":false}'::jsonb,18),
('scm_centro_custo','FP&A','FP&A','{"camm":null,"compartilhado":true}'::jsonb,19),
('scm_centro_custo','FRACIONAMENTO DE MP','FRACIONAMENTO DE MP','{"camm":null,"compartilhado":true}'::jsonb,20),
('scm_centro_custo','FROTAS','FROTAS','{"camm":null,"compartilhado":true}'::jsonb,21),
('scm_centro_custo','INOVAÇÃO','INOVAÇÃO','{"camm":null,"compartilhado":true}'::jsonb,22),
('scm_centro_custo','LABORATÓRIO','LABORATÓRIO','{"camm":null,"compartilhado":true}'::jsonb,23),
('scm_centro_custo','LOGÍSTICA INTERNA','LOGÍSTICA INTERNA','{"camm":null,"compartilhado":true}'::jsonb,24),
('scm_centro_custo','LOGÍSTICA INTERNA - CAMM 3','LOGÍSTICA INTERNA - CAMM 3','{"camm":"CAMM 3","compartilhado":false}'::jsonb,25),
('scm_centro_custo','MANUTENÇÃO','MANUTENÇÃO','{"camm":null,"compartilhado":true}'::jsonb,26),
('scm_centro_custo','MANUTENÇÃO E ENGENHARIA - CAMM 3','MANUTENÇÃO E ENGENHARIA - CAMM 3','{"camm":"CAMM 3","compartilhado":false}'::jsonb,27),
('scm_centro_custo','MANUTENÇÃO PREDIAL (FACILITIES)','MANUTENÇÃO PREDIAL (FACILITIES)','{"camm":null,"compartilhado":true}'::jsonb,28),
('scm_centro_custo','MELHORIA CONTÍNUA','MELHORIA CONTÍNUA','{"camm":null,"compartilhado":true}'::jsonb,29),
('scm_centro_custo','PCP','PCP','{"camm":null,"compartilhado":true}'::jsonb,30),
('scm_centro_custo','PESQUISA','PESQUISA','{"camm":null,"compartilhado":true}'::jsonb,31),
('scm_centro_custo','QUALIDADE','QUALIDADE','{"camm":null,"compartilhado":true}'::jsonb,32),
('scm_centro_custo','RECRUTAMENTO E SELEÇÃO','RECRUTAMENTO E SELEÇÃO','{"camm":null,"compartilhado":true}'::jsonb,33),
('scm_centro_custo','REGULATÓRIO','REGULATÓRIO','{"camm":null,"compartilhado":true}'::jsonb,34),
('scm_centro_custo','S&OP','S&OP','{"camm":null,"compartilhado":true}'::jsonb,35),
('scm_centro_custo','SEGURANÇA DO TRABALHO - CAMM 3','SEGURANÇA DO TRABALHO - CAMM 3','{"camm":"CAMM 3","compartilhado":false}'::jsonb,36),
('scm_centro_custo','SEGURANÇA DO TRABALHO - G&A','SEGURANÇA DO TRABALHO - G&A','{"camm":null,"compartilhado":true}'::jsonb,37),
('scm_centro_custo','SEGURANÇA DO TRABALHO - PRODUÇÃO','SEGURANÇA DO TRABALHO - PRODUÇÃO','{"camm":null,"compartilhado":true}'::jsonb,38),
('scm_centro_custo','TESOURARIA','TESOURARIA','{"camm":null,"compartilhado":true}'::jsonb,39),
('scm_centro_custo','TI','TI','{"camm":null,"compartilhado":true}'::jsonb,40),
('scm_centro_custo','UTILIDADES','UTILIDADES','{"camm":null,"compartilhado":true}'::jsonb,41),
('scm_centro_custo','UTILIDADES - CAMM 3','UTILIDADES - CAMM 3','{"camm":"CAMM 3","compartilhado":false}'::jsonb,42),
('scm_centro_custo','VENDAS INDUSTRIAIS B2B','VENDAS INDUSTRIAIS B2B','{"camm":null,"compartilhado":true}'::jsonb,43),
('scm_centro_custo','Outro','Outro','{"camm":null,"compartilhado":true}'::jsonb,44),
('scm_tipo_fornecedor','normal','Normal','{}'::jsonb,0),
('scm_tipo_fornecedor','escolhido','Escolhido','{}'::jsonb,1),
('scm_tipo_fornecedor','exclusivo','Exclusivo','{}'::jsonb,2),
('scm_tipo_pedido','compra_material','Compra de Material','{}'::jsonb,0),
('scm_tipo_pedido','contratacao_servico_pcm','Contratação de Serviço (PCM)','{}'::jsonb,1),
('scm_tipo_pedido','solicitacao_manutencao_externa','Solicitação de Manutenção Externa','{}'::jsonb,2),
('sci_familia','parafuso','Parafuso','{"campos":[{"id":"material_construtivo","label":"MATERIAL CONSTRUTIVO","obrigatorio":true},{"id":"revestimento_acabamento","label":"REVESTIMENTO/ ACABAMENTO","obrigatorio":true},{"id":"tipo_rosca","label":"TIPO ROSCA","obrigatorio":true},{"id":"passo_fio","label":"PASSO/FIO","obrigatorio":false},{"id":"comprimento_rosca","label":"COMPRIMENTO ROSCA","obrigatorio":true},{"id":"norma","label":"NORMA","obrigatorio":false},{"id":"diametro","label":"DIAMETRO","obrigatorio":true},{"id":"comprimento_total","label":"COMPRIMENTO TOTAL","obrigatorio":true},{"id":"tipo_cabeca","label":"TIPO CABEÇA","obrigatorio":true},{"id":"tipo_de_acionamento","label":"TIPO DE ACIONAMENTO","obrigatorio":true},{"id":"sentido_rosca","label":"SENTIDO ROSCA","obrigatorio":true}]}'::jsonb,0),
('sci_familia','porca','Porca','{"campos":[{"id":"tipo","label":"TIPO","obrigatorio":true},{"id":"material_construtivo","label":"MATERIAL CONSTRUTIVO","obrigatorio":true},{"id":"acabamento","label":"ACABAMENTO","obrigatorio":true},{"id":"tipo_rosca","label":"TIPO ROSCA","obrigatorio":true},{"id":"passo_de_rosca","label":"PASSO DE ROSCA","obrigatorio":true},{"id":"classe_de_resistencia","label":"CLASSE DE RESISTÊNCIA","obrigatorio":true},{"id":"unidade_de_medida","label":"UNIDADE DE MEDIDA","obrigatorio":true},{"id":"diametro","label":"DIÂMETRO","obrigatorio":true},{"id":"norma","label":"NORMA","obrigatorio":false}]}'::jsonb,1),
('sci_familia','componente_especifico','Componente Específico','{"campos":[{"id":"nome_da_peca","label":"NOME DA PECA","obrigatorio":true},{"id":"material","label":"MATERIAL","obrigatorio":true},{"id":"dimensoes","label":"DIMENSOES","obrigatorio":true},{"id":"aplicacao","label":"APLICACAO","obrigatorio":true},{"id":"dados_adicionais","label":"DADOS ADICIONAIS","obrigatorio":true},{"id":"fabricante","label":"FABRICANTE","obrigatorio":true},{"id":"referencia_fabricante","label":"REFERENCIA FABRICANTE","obrigatorio":true}]}'::jsonb,2),
('sci_familia','arruela','Arruela','{"campos":[{"id":"tipo","label":"TIPO","obrigatorio":true},{"id":"material_construtivo","label":"MATERIAL CONSTRUTIVO","obrigatorio":true},{"id":"acabamento","label":"ACABAMENTO","obrigatorio":true},{"id":"norma","label":"NORMA","obrigatorio":true},{"id":"perfil","label":"PERFIL","obrigatorio":true},{"id":"medidas","label":"MEDIDAS","obrigatorio":true},{"id":"espessura","label":"ESPESSURA","obrigatorio":true}]}'::jsonb,3),
('sci_familia','tubos_e_conex_es','Tubos e Conexões','{"campos":[{"id":"tipo_de_conexao","label":"TIPO DE CONEXÃO","obrigatorio":true},{"id":"angulo","label":"ÂNGULO","obrigatorio":false},{"id":"material","label":"MATERIAL","obrigatorio":true},{"id":"acabamento_revestimento","label":"ACABAMENTO/REVESTIMENTO","obrigatorio":false},{"id":"cor","label":"COR","obrigatorio":false},{"id":"diametro_nominal","label":"DIÂMETRO NOMINAL","obrigatorio":true},{"id":"espessura","label":"ESPESSURA","obrigatorio":true},{"id":"extremidade","label":"EXTREMIDADE","obrigatorio":true},{"id":"norma","label":"NORMA","obrigatorio":true}]}'::jsonb,4),
('sci_familia','bucha_de_fixacao','Bucha de Fixação','{"campos":[{"id":"tipo","label":"TIPO","obrigatorio":true},{"id":"material","label":"MATERIAL","obrigatorio":true},{"id":"diametro","label":"DIAMETRO","obrigatorio":true},{"id":"comprimento","label":"COMPRIMENTO","obrigatorio":true},{"id":"carga_aplicacao","label":"CARGA/APLICAÇÃO","obrigatorio":true},{"id":"diametro_parafuso","label":"DIÂMETRO PARAFUSO","obrigatorio":true}]}'::jsonb,5),
('sci_familia','valvulas','Válvulas','{"campos":[{"id":"tipo","label":"TIPO","obrigatorio":true},{"id":"diametro_nominal","label":"DIÂMETRO NOMINAL","obrigatorio":true},{"id":"tipo_conexao","label":"TIPO CONEXÃO","obrigatorio":true},{"id":"pressao_maxima_de_trabalho","label":"PRESSÃO MÁXIMA DE TRABALHO","obrigatorio":true},{"id":"material_construtivo","label":"MATERIAL CONSTRUTIVO","obrigatorio":true},{"id":"material_vedacao_interna","label":"MATERIAL VEDAÇÃO INTERNA","obrigatorio":true},{"id":"acionamento","label":"ACIONAMENTO","obrigatorio":true},{"id":"faixa_de_temperatura_trabalho","label":"FAIXA DE TEMPERATURA TRABALHO","obrigatorio":false},{"id":"fluido_aplicacao","label":"FLUIDO/ APLICAÇÃO","obrigatorio":false},{"id":"vias","label":"VIAS","obrigatorio":true},{"id":"classe","label":"CLASSE","obrigatorio":false}]}'::jsonb,6),
('sci_familia','vedacao','Vedação','{"campos":[{"id":"tipo","label":"TIPO","obrigatorio":true},{"id":"formato_perfil","label":"FORMATO/ PERFIL","obrigatorio":true},{"id":"material","label":"MATERIAL","obrigatorio":true},{"id":"dureza_shore","label":"DUREZA/ SHORE","obrigatorio":false},{"id":"medidas","label":"MEDIDAS","obrigatorio":true},{"id":"espessura","label":"ESPESSURA","obrigatorio":true},{"id":"faixa_de_temperatura","label":"FAIXA DE TEMPERATURA","obrigatorio":true},{"id":"norma","label":"NORMA","obrigatorio":false},{"id":"aplicacao","label":"APLICAÇÃO","obrigatorio":false}]}'::jsonb,7),
('sci_familia','outros','Outros','{"campos":[{"id":"descricao_completa","label":"DESCRIÇÃO COMPLETA","obrigatorio":true},{"id":"material","label":"MATERIAL","obrigatorio":true},{"id":"medidas","label":"MEDIDAS","obrigatorio":true},{"id":"aplicacao","label":"APLICAÇÃO","obrigatorio":true},{"id":"norma","label":"NORMA","obrigatorio":false}]}'::jsonb,8)
on conflict (scope,item_key) do update set label=excluded.label,metadata=excluded.metadata,sort_order=excluded.sort_order,active=true,updated_at=now();
do $$
begin
 if exists(select 1 from pg_publication where pubname='supabase_realtime') and not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='pcm_master_data') then
  execute 'alter publication supabase_realtime add table public.pcm_master_data';
 end if;
end $$;
alter table public.pcm_master_data replica identity full;
