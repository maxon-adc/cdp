﻿using Core.Entities;
using DAL.Mappers.Implementations;
using DAL.Mappers.Interfaces;
using DAL.Repositories.Interfaces;
using DAL.SqlExpressionProviders.Implementations;
using DAL.SqlExpressionProviders.Interfaces;
using Dapper;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace DAL.Repositories.Implementations
{
	public class DapperRepository<TEntity> : IRepository<TEntity> where TEntity : BaseEntity
	{
		private readonly IDbConnection _connection;
		private readonly IDbTransaction _transaction;
		private readonly ISqlExpressionProvider _expressionProvider;
		private readonly IDataMapper<TEntity> _dataMapper;

		private readonly string _tableName;

		public DapperRepository(IDbConnection connection, IDbTransaction transaction)
		{
			_connection = connection;
			_transaction = transaction;
			_expressionProvider = new SqlExpressionProvider();
			_dataMapper = new DataMapper<TEntity>();
			_tableName = typeof(TEntity).Name;
		}

		public TEntity Create(TEntity entity)
		{
			var properties = _dataMapper.MapToProperties(entity);
			var expression = _expressionProvider.ProvideCreateExpressionWithSelectIdentity(_tableName, properties);
			var id = _connection.Query<int>(expression, entity, _transaction).Single();
			expression = _expressionProvider.ProvideReadOneExpression(_tableName, id);
			entity = _connection.QueryFirstOrDefault<TEntity>(expression, null, _transaction);

			return entity;
		}

		public TEntity ReadOne(int id)
		{
			var expression = _expressionProvider.ProvideReadOneExpression(_tableName, id);
			var entity = _connection.QueryFirstOrDefault<TEntity>(expression, null, _transaction);

			return entity;
		}

		public IEnumerable<TEntity> ReadAll()
		{
			var expression = _expressionProvider.ProvideReadAllExpression(_tableName);
			var entities = _connection.Query<TEntity>(expression, null, _transaction).ToList();

			return entities;
		}

		public void Update(TEntity entity)
		{
			var properties = _dataMapper.MapToProperties(entity);
			var expression = _expressionProvider.ProvideUpdateExpression(_tableName, entity.Id, properties);

			_connection.Execute(expression, entity, _transaction);
		}

		public void Delete(int id)
		{
			var expression = _expressionProvider.ProvideDeleteExpression(_tableName, id);

			_connection.Execute(expression, null, _transaction);
		}
	}
}
